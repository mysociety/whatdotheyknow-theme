##
# Job to republish or report to admins files stored as ActiveStorage::Blob
#
# Examples:
#   ExcelAnalyzer::RepublishOrReportJob.perform(ActiveStorage::Blob.first)
#
module ExcelAnalyzer
  class RepublishOrReportJob < ApplicationJob
    queue_as :excel_analyzer

    attr_reader :attachment_blob
    delegate :info_request, :incoming_message, to: :attachment

    def perform(attachment_blob)
      @attachment_blob = attachment_blob

      if safe_to_republish?
        # Republish attachment
        attachment.update_and_log_event(
          prominence: hide_event.params[:old_prominence],
          prominence_reason: hide_event.params[:old_prominence_reason],
          event: { editor: User.internal_admin_user }
        ) && attachment.log_event("manual", {
          attachment: attachment,
          type: "excel-analyzer-safe",
          reason: "No data breach found after automated review"
        })
      else
        # Report attachment
        ExcelAnalyzer::NotifierMailer.report(attachment_blob).deliver_now
      end
    end

    private

    def safe_to_republish?
      !potential_pii_leaks? &&
        !(xls? && pivot_cache?) &&
        !(named_ranges? && external_links?) &&
        !(data_model?)
    end

    def potential_pii_leaks?
      attachment_blob.metadata[:pii_badger][:potential_pii_leaks].any?
    end

    def xls?
      attachment_blob.content_type == ExcelAnalyzer::XlsAnalyzer::CONTENT_TYPE
    end

    def pivot_cache?
      attachment_blob.metadata[:excel][:pivot_cache] > 0
    end

    def named_ranges?
      attachment_blob.metadata[:excel][:named_ranges] > 0
    end

    def external_links?
      attachment_blob.metadata[:excel][:external_links] > 0
    end

    def data_model?
      attachment_blob.metadata[:excel][:data_model] > 0
    end

    def attachment
      @attachment ||= FoiAttachment.joins(:file_blob).find_by(
        active_storage_blobs: { id: attachment_blob.to_param }
      )
    end

    def hide_event
      attachment.info_request.info_request_events.
        where(event_type: "edit_attachment").
        where("params->>'attachment_id' = ?", attachment.to_param).
        where("params->>'reason' = ?", "ExcelAnalyzer: hidden data detected").
        first
    end
  end
end
