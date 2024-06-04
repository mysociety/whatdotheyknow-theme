require_relative '../../spec_helper'

RSpec.describe ExcelAnalyzer::RepublishOrReportJob, type: :job do
  let(:message) { FactoryBot.create(:incoming_message) }
  let(:attachment) { message.foi_attachments.first }
  let(:blob) { attachment.file_blob }

  let(:excel_metadata) do
    { pivot_cache: 0, named_ranges: 0, external_links: 0, data_model: 0 }
  end
  let(:pii_metadata) { { potential_pii_leaks: [] } }

  around do |example|
    to = ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL']
    ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL'] = 'excel@localhost'
    example.call
    ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL'] = to
  end

  before do
    # set blob content type and metadata
    blob.update(
      content_type: ExcelAnalyzer::XlsxAnalyzer::CONTENT_TYPE,
      metadata: blob.metadata.merge(
        excel: excel_metadata,
        pii_badger: pii_metadata
      )
    )

    # hide attachment
    attachment.update(prominence: 'hidden')

    # create hide event
    message.info_request.info_request_events.create(
      event_type: 'edit_attachment', params: {
        attachment_id: attachment.id,
        reason: 'ExcelAnalyzer: hidden data detected',
        old_prominence: 'normal',
        old_prominence_reason: ''
      }
    )
  end

  def perform
    described_class.new.perform(blob)
  end

  it 'republished attachment' do
    expect { perform; attachment.reload }.to change(attachment, :prominence).
      from('hidden').to('normal')
  end

  it 'logs manual safe event' do
    perform
    event = message.info_request.info_request_events.last
    expect(event.event_type).to eq('manual')
    expect(event.params[:type]).to eq('excel-analyzer-safe')
    expect(event.params[:reason]).
      to eq('No data breach found after automated review')
  end

  shared_examples :attachment_reported do
    it 'sents report email' do
      deliveries = ActionMailer::Base.deliveries
      expect(deliveries.size).to eq(0)

      expect(ExcelAnalyzer::NotifierMailer).to receive(:report).with(blob).
        and_call_original
      perform
      expect(deliveries.size).to eq(1)

      deliveries.clear
    end
  end

  context 'when potential PII leaks were detected' do
    let(:pii_metadata) { { potential_pii_leaks: [:foo] } }
    include_examples :attachment_reported
  end

  context 'when XLS and pivot cache present' do
    let(:excel_metadata) { { pivot_cache: 1 } }
    before { blob.content_type = ExcelAnalyzer::XlsAnalyzer::CONTENT_TYPE }
    include_examples :attachment_reported
  end

  context 'when named ranges and external links present' do
    let(:excel_metadata) do
      { pivot_cache: 0, named_ranges: 1, external_links: 1 }
    end

    include_examples :attachment_reported
  end

  context 'when data model present' do
    let(:excel_metadata) do
      { pivot_cache: 0, named_ranges: 0, external_links: 0, data_model: 1 }
    end

    include_examples :attachment_reported
  end
end
