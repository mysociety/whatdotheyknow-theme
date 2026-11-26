require_relative '../../spec_helper'

RSpec.describe ExcelAnalyzer::PIIBadgerJob, type: :job do
  let(:message) { FactoryBot.create(:incoming_message) }
  let(:attachment) { message.foi_attachments.first }
  let(:blob) { attachment.file_blob }

  let(:excel_metadata) { { foo: 'baz' } }
  let(:pii_metadata) { { bar: 'baz' } }

  let(:xc) do
    instance_double(
      ExternalCommand,
      exited: true, status: 0, timed_out: nil,
      out: pii_metadata.to_json.b, err: ''.b
    )
  end

  around do |example|
    cmd = ENV['EXCEL_ANALYZER_PII_BADGER_COMMAND']
    ENV['EXCEL_ANALYZER_PII_BADGER_COMMAND'] = '/usr/bin/pii_badger.sh analyze'
    example.call
    ENV['EXCEL_ANALYZER_PII_BADGER_COMMAND'] = cmd
  end

  before do
    # Seed :excel via a separate instance so the job's in-memory blob is stale,
    # mirroring ActiveStorage persisting the analyzer metadata concurrently.
    other = ActiveStorage::Blob.find(blob.id)
    other.update(metadata: other.metadata.merge(excel: excel_metadata))

    allow(ExternalCommand).to receive(:new).and_return(xc)
    allow(xc).to receive(:run).and_return(xc)
  end

  def perform
    described_class.new.perform(blob)
  end

  def error
    blob.reload.metadata[:pii_badger][:error]
  end

  it 'calls external command' do
    expect(ExternalCommand).to receive(:new).with(
      '/usr/bin/pii_badger.sh', 'analyze', '--file', %r(^/), timeout: 900
    )
    perform
  end

  it 'updates the blob metadata' do
    expect { perform }.to change(blob, :metadata)
    expect(blob.metadata).to include(pii_badger: hash_including(pii_metadata))
  end

  it 'stores how long PII Badger ran for' do
    freeze_time
    allow(xc).to receive(:run) do
      travel(10.seconds)
      xc
    end
    perform
    expect(blob.reload.metadata[:pii_badger]).
      to eq('bar' => 'baz', 'duration' => 10.0)
  end

  it 'preserves concurrently persisted excel metadata' do
    perform
    expect(blob.reload.metadata).
      to include(
        excel: excel_metadata, pii_badger: hash_including(pii_metadata)
      )
  end

  it 'queues Republish or Report job' do
    expect(ExcelAnalyzer::RepublishOrReportJob).to receive(:perform_later).
      with(blob)
    perform
  end

  context 'when the command fails' do
    let(:xc) do
      instance_double(
        ExternalCommand,
        exited: true, status: 1, timed_out: nil,
        out: ''.b, err: "INFO starting\nValueError: bad XML │\n".b
      )
    end

    it 'stores the exit status and stderr as the error' do
      perform
      expect(error).to eq(
        "Exited with status 1\nINFO starting\nValueError: bad XML │"
      )
    end

    it 'queues Republish or Report job' do
      expect(ExcelAnalyzer::RepublishOrReportJob).to receive(:perform_later).
        with(blob)
      perform
    end
  end

  context 'when the command times out' do
    let(:xc) do
      instance_double(
        ExternalCommand,
        exited: false, status: nil, timed_out: true, out: ''.b, err: ''.b
      )
    end

    it 'stores the timeout as the error' do
      perform
      expect(error).to eq('Timed out after 15 minutes')
    end
  end

  context 'when the command is killed' do
    let(:xc) do
      instance_double(
        ExternalCommand,
        exited: false, status: nil, timed_out: nil, out: ''.b, err: ''.b
      )
    end

    it 'stores the abnormal termination as the error' do
      perform
      expect(error).to eq('Terminated abnormally')
    end
  end

  context 'when the command returns invalid JSON' do
    let(:xc) do
      instance_double(
        ExternalCommand,
        exited: true, status: 0, timed_out: nil, out: ''.b, err: ''.b
      )
    end

    it 'stores the parser error' do
      perform
      expect(error).to start_with('JSON::ParserError: ')
    end
  end

  context 'when the command can not be run' do
    before do
      allow(xc).to receive(:run).
        and_raise(ArgumentError, 'marshal data too short')
    end

    it 'stores the exception as the error' do
      perform
      expect(error).to eq('ArgumentError: marshal data too short')
    end
  end
end
