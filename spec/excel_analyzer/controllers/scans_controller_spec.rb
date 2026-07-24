require_relative '../../spec_helper'

RSpec.describe ExcelAnalyzer::ScansController, type: :controller do
  let(:admin_user) { FactoryBot.create(:admin_user) }

  before { sign_in(admin_user) }

  let(:info_request) { FactoryBot.create(:info_request, :with_plain_incoming) }
  let(:incoming_message) { info_request.incoming_messages.first }
  let!(:attachment) { incoming_message.foi_attachments.first }

  before do
    attachment.file_blob.update(
      content_type: ExcelAnalyzer::XlsxAnalyzer::CONTENT_TYPE
    )
  end

  describe 'POST #create' do
    let(:params) { { foi_attachment_id: attachment.id } }

    it 'assigns the attachment' do
      post :create, params: params
      expect(assigns[:foi_attachment]).to eq(attachment)
    end

    it 'queues re-analysis of the attachment blob' do
      expect { post :create, params: params }.
        to have_enqueued_job(ActiveStorage::AnalyzeJob)
    end

    it 'sets a success notice' do
      post :create, params: params
      expect(flash[:notice]).to eq('Re-scan queued.')
    end

    it 'redirects to the attachment edit page' do
      post :create, params: params
      expect(response).to redirect_to(
        edit_admin_foi_attachment_path(attachment)
      )
    end

    context 'when the admin cannot access the request' do
      before { allow(controller).to receive(:can?).and_return(false) }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { post :create, params: params }.
          to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
