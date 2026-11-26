##
# Allow admins to re-run the ExcelAnalyzer analysis on a FoiAttachment, or to
# re-run PII Badger on a FoiAttachment that ExcelAnalyzer hid.
#
# Re-analysing the blob repopulates its :excel metadata and re-fires the
# on_hidden_metadata flow (hide + PII Badger) for suspect files.
#
module ExcelAnalyzer
  class ScansController < AdminController
    before_action :set_foi_attachment, :set_incoming_message, :set_info_request
    before_action :check_info_request

    def create
      @foi_attachment.file_blob.analyze_later
      redirect_to edit_admin_foi_attachment_path(@foi_attachment),
                  notice: 'Re-scan queued.'
    end

    def pii_badger
      if ExcelAnalyzer.hidden?(@foi_attachment)
        ExcelAnalyzer::PIIBadgerJob.perform_later(@foi_attachment.file_blob)
        notice = 'PII Badger run queued.'
      else
        notice = 'PII Badger only runs on files that ExcelAnalyzer hid.'
      end

      redirect_to edit_admin_foi_attachment_path(@foi_attachment),
                  notice: notice
    end

    private

    def set_foi_attachment
      @foi_attachment = FoiAttachment.find(params[:foi_attachment_id])
    end

    def set_incoming_message
      @incoming_message = @foi_attachment&.incoming_message
    end

    def set_info_request
      @info_request = @incoming_message&.info_request
    end

    def check_info_request
      return if can? :admin, @info_request

      raise ActiveRecord::RecordNotFound
    end
  end
end
