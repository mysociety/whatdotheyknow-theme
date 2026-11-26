require_relative '../../spec_helper'

RSpec.describe ExcelAnalyzer::NotifierMailer do
  let(:message) { FactoryBot.create(:incoming_message) }
  let(:attachment) { message.foi_attachments.first }
  let(:blob) { attachment.file_blob }

  let(:reasons) { [:potential_pii_leaks, :data_model] }

  let(:mail) do
    described_class.report(blob, reasons).deliver_now
    ActionMailer::Base.deliveries[-1]
  end

  around do |example|
    to = ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL']
    ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL'] = 'excel@localhost'
    example.call
    ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL'] = to
  end

  before do
    allow(blob).to receive(:metadata).and_return(excel: {})
  end

  after { ActionMailer::Base.deliveries.clear }

  it 'has custom mail headers' do
    expect(mail['X-WDTK-Contact'].value).to eq('wdtk-excel-analyzer-report')
    expect(mail['X-WDTK-CaseRef'].value).to eq(attachment.to_param)
  end

  it 'refers to the same thread for each report on the attachment' do
    thread_id = "excel-analyzer-#{attachment.id}@" \
      "#{AlaveteliConfiguration.incoming_email_domain}"
    expect(mail.in_reply_to).to eq(thread_id)
    expect(mail.references).to eq(thread_id)
    expect(mail.message_id).not_to eq(thread_id)
  end

  it 'sents mail from and to the correct addresses' do
    expect(mail.from).to include(blackhole_email)
    expect(mail.to).to include(ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL'])
  end

  it 'has attachment ID in the subject' do
    expect(mail.subject).
      to eq("ExcelAnalyzer: hidden data detected [#{attachment.id}]")
  end

  it 'lists the reasons in the body' do
    expect(mail.body).to include(<<~TXT)
      It needs a review because:
      - PII Badger found possible personal data
      - Data model present
    TXT
  end

  it 'includes the admin URL in the body' do
    expect(mail.body).
      to include("http://test.host/admin/requests/#{message.info_request_id}")
    expect(mail.body).
      to include("http://test.host/admin/attachments/#{attachment.id}/edit")
  end

  it 'lists the Excel Analyzer counts that are not zero in the body' do
    allow(blob).to receive(:metadata).and_return(
      excel: { hidden_rows: 112, hidden_sheets: 0, named_ranges: 1 }
    )
    expect(mail.body).to include(<<~TXT)
      Excel Analyzer findings:
      - hidden_rows: 112
      - named_ranges: 1

    TXT
  end

  it 'summarises the PII Badger leaks in the body' do
    allow(blob).to receive(:metadata).and_return(
      excel: {},
      pii_badger: {
        potential_pii_leaks: [
          { source: 'Pivot Cache', pii_type: 'PERSON', count: 2965,
            average_confidence: 0.8499999999999526 }
        ]
      }
    )
    expect(mail.body).to include(<<~TXT)
      PII Badger findings:
      - Pivot Cache: PERSON (2965 matches, average confidence 0.85)
    TXT
  end

  it 'includes how long PII Badger ran for in the body' do
    allow(blob).to receive(:metadata).and_return(
      excel: {}, pii_badger: { duration: 9.6, potential_pii_leaks: [] }
    )
    expect(mail.body).to include('PII Badger ran for 9.6 seconds.')
  end

  it 'rounds a PII Badger run time over a minute to whole seconds' do
    allow(blob).to receive(:metadata).and_return(
      excel: {}, pii_badger: { duration: 605.3, potential_pii_leaks: [] }
    )
    expect(mail.body).to include('PII Badger ran for 10 minutes and 5 seconds.')
  end

  it 'includes the PII Badger error as plain text in the body' do
    allow(blob).to receive(:metadata).and_return(
      excel: {}, pii_badger: { error: "Exited with status 1\nValueError" }
    )
    expect(mail.body).to include(<<~TXT)
      PII Badger could not scan this file for personal data. To try again, use
      "Re-run PII Badger" on the admin attachment page.

      PII Badger error:
      Exited with status 1
      ValueError
    TXT
    expect(mail.body).not_to include('PII Badger findings')
  end
end
