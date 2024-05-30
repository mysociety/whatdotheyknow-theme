require_relative '../../spec_helper'

RSpec.describe ExcelAnalyzer::NotifierMailer do
  let(:message) { FactoryBot.create(:incoming_message) }
  let(:attachment) { message.foi_attachments.first }
  let(:blob) { attachment.file_blob }

  let(:mail) do
    described_class.report(blob).deliver_now
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

  it 'sents mail from and to the correct addresses' do
    expect(mail.from).to include(blackhole_email)
    expect(mail.to).to include(ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL'])
  end

  it 'has attachment ID in the subject' do
    expect(mail.subject).
      to eq("ExcelAnalyzer: hidden data detected [#{attachment.id}]")
  end

  it 'includes the admin URL in the body' do
    expect(mail.body).
      to include("http://test.host/admin/requests/#{message.info_request_id}")
    expect(mail.body).
      to include("http://test.host/admin/attachments/#{attachment.id}/edit")
  end

  it 'includes the metadata in the body' do
    allow(blob).to receive(:metadata).and_return(
      excel: { foo: 'bar' }, pii_badger: { baz: 'qux' }
    )
    expect(mail.body).to include('"foo": "bar"')
    expect(mail.body).to include('"baz": "qux"')
  end
end
