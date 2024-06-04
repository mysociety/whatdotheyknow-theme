require_relative '../../spec_helper'

RSpec.describe ExcelAnalyzer::PIIBadgerJob, type: :job do
  let(:message) { FactoryBot.create(:incoming_message) }
  let(:attachment) { message.foi_attachments.first }
  let(:blob) { attachment.file_blob }

  let(:excel_metadata) { { foo: 'baz' } }
  let(:pii_metadata) { { bar: 'baz' } }

  around do |example|
    cmd = ENV['EXCEL_ANALYZER_PII_BADGER_COMMAND']
    ENV['EXCEL_ANALYZER_PII_BADGER_COMMAND'] = '/usr/bin/pii_badger.sh'
    example.call
    ENV['EXCEL_ANALYZER_PII_BADGER_COMMAND'] = cmd
  end

  before do
    blob.update(metadata: blob.metadata.merge(excel: excel_metadata))
    allow(IO).to receive(:popen).and_return(pii_metadata)
  end

  def perform
    described_class.new.perform(blob)
  end

  it 'calls external command' do
    expect(IO).to receive(:popen).with(%r(^/usr/bin/pii_badger.sh --file /.*$))
    perform
  end

  it 'updates the blob metadata' do
    expect { perform }.to change(blob, :metadata)
    expect(blob.metadata).to include(pii_badger: pii_metadata)
  end

  it 'queues Republish or Report job' do
    expect(ExcelAnalyzer::RepublishOrReportJob).to receive(:perform_later).
      with(blob)
    perform
  end
end
