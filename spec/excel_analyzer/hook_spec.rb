require_relative '../spec_helper'

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

  it 'queues PII Badger job' do
    expect(ExcelAnalyzer::PIIBadgerJob).to receive(:perform_later).with(blob)
    ExcelAnalyzer.on_hidden_metadata.call(blob, blob.metadata)
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
