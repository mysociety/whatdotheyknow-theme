require_relative 'spec_helper'

RSpec.describe 'ExcelAnalyzer on_hidden_metadata hook' do
  let(:message) { FactoryBot.create(:incoming_message, sent_at: Time.now) }
  let(:attachment) { message.foi_attachments.first }
  let(:blob) { attachment.file_blob }

  around do |example|
    to = ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL']
    ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL'] = 'excel@localhost'
    example.call
    ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL'] = to
  end

  it 'hides the attachment with prominence reason' do
    expect(attachment.prominence).to eq('normal')
    expect(attachment.prominence_reason).to be_nil

    ExcelAnalyzer.on_hidden_metadata.call(blob, blob.metadata)
    attachment.reload

    expect(attachment.prominence).to eq('hidden')
    expect(attachment.prominence_reason).to eq(<<~TXT.squish)
      We've found a problem with this file, so it's been hidden while we review
      it. We might not be able to give more details until then.
    TXT
  end

  it 'sents report email' do
    deliveries = ActionMailer::Base.deliveries
    expect(deliveries.size).to eq(0)

    expect(ExcelAnalyzerNotifier).to receive(:report).
      with(attachment, blob.metadata).
      and_call_original
    ExcelAnalyzer.on_hidden_metadata.call(blob, blob.metadata)
    expect(deliveries.size).to eq(1)

    deliveries.clear
  end

  context 'when message was sent more than 1 day ago' do
    let(:message) do
      FactoryBot.create(:incoming_message, sent_at: 24.hours.ago - 1.minute)
    end

    it 'does not hide the attachment' do
      expect { ExcelAnalyzer.on_hidden_metadata.call(blob, blob.metadata) }.
        to_not change(attachment, :prominence)
    end

    it 'sents no email' do
      deliveries = ActionMailer::Base.deliveries
      expect(deliveries.size).to eq(0)
      ExcelAnalyzer.on_hidden_metadata.call(blob, blob.metadata)
      expect(deliveries.size).to eq(0)
    end
  end
end

RSpec.describe 'ExcelAnalyzerNotifier report mail' do
  let(:message) { FactoryBot.create(:incoming_message, sent_at: Time.now) }
  let(:attachment) { message.foi_attachments.first }
  let(:blob) { attachment.file_blob }

  let(:mail) do
    ExcelAnalyzerNotifier.report(attachment, blob.metadata).deliver_now
    ActionMailer::Base.deliveries[-1]
  end

  around do |example|
    to = ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL']
    ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL'] = 'excel@localhost'
    example.call
    ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL'] = to
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
    allow(blob).to receive(:metadata).and_return(foo: 'bar')
    expect(mail.body).to include("foo: bar")
  end
end
