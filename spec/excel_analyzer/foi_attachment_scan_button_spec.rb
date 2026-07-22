require_relative '../spec_helper'

RSpec.describe Admin::FoiAttachmentsController, type: :controller do
  render_views

  let(:admin_user) { FactoryBot.create(:admin_user) }

  before { sign_in(admin_user) }

  let(:info_request) { FactoryBot.create(:info_request, :with_plain_incoming) }
  let(:incoming_message) { info_request.incoming_messages.first }
  let!(:attachment) { incoming_message.foi_attachments.first }

  describe 'GET edit' do
    context 'when the attachment is a spreadsheet' do
      before do
        attachment.file_blob.update(
          content_type: ExcelAnalyzer::XlsxAnalyzer::CONTENT_TYPE
        )
      end

      it 'shows the re-scan button' do
        get :edit, params: { id: attachment.id }
        expect(response.body).to have_button('Re-scan for hidden data')
      end
    end

    context 'when the attachment is not a spreadsheet' do
      it 'does not show the re-scan button' do
        get :edit, params: { id: attachment.id }
        expect(response.body).not_to have_button('Re-scan for hidden data')
      end
    end
  end
end
