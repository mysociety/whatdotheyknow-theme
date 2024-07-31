require_relative '../../spec_helper'

RSpec.describe RequestMailer, type: :mailer do
  describe '#new_response' do
    let(:info_request) { incoming_message.info_request }
    let(:incoming_message) { FactoryBot.create(:incoming_message) }
    let(:attachment) { incoming_message.foi_attachments.first }
    let(:blob) { attachment.file_blob }

    context 'when the email is older than 30 minutes' do
      before do
        allow(incoming_message).to receive(:sent_at).and_return(31.minutes.ago)
      end

      it 'does not deliver the email' do
        mail = subject.new_response(info_request, incoming_message)
        expect(mail).to be_nil
      end
    end

    context 'when the attachments have not been analyzed' do
      before do
        blob.update(metadata: nil)
        allow(incoming_message).to receive(:sent_at).and_return(Time.current)
      end

      it 'retrys the email after a delay' do
        expect { subject.new_response(info_request, incoming_message) }.to(
          have_enqueued_mail(described_class, :new_response).
          with(info_request, incoming_message)
        )
      end

      it 'does not deliver the email' do
        mail = subject.new_response(info_request, incoming_message)
        expect(mail).to be_nil
      end
    end

    context 'when there are hidden attachments' do
      let!(:attachment) do
        FactoryBot.create(
          :foi_attachment,
          incoming_message: incoming_message,
          prominence: 'hidden',
          prominence_reason: ExcelAnalyzer::PROMINENCE_REASON
        )
      end

      before do
        blob.update(metadata: { analyzed: true })
        allow(incoming_message).to receive(:sent_at).and_return(Time.current)
      end

      it 'retrys the email after a delay' do
        expect { subject.new_response(info_request, incoming_message) }.to(
          have_enqueued_mail(described_class, :new_response).
          with(info_request, incoming_message)
        )
      end

      it 'does not deliver the email' do
        mail = subject.new_response(info_request, incoming_message)
        expect(mail).to be_nil
      end
    end

    context 'when there are no hidden attachments and the email is recent' do
      before do
        blob.update(metadata: { analyzed: true })
        allow(incoming_message).to receive(:sent_at).and_return(Time.current)
      end

      it 'delivers the email immediately' do
        mail = subject.new_response(info_request, incoming_message)
        expect(mail).to be_a(Mail::Message)
      end
    end
  end
end
