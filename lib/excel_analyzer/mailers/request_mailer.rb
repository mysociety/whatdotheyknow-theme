module ExcelAnalyzer
  module RequestMailer
    def new_response(info_request, incoming_message)
      # Don't deliver new response email if 30 minutes has elapsed
      return if incoming_message.sent_at < 30.minutes.ago

      # Wait 5 minutes if the attachments haven't been processed, I.E.
      # ActiveStorage has completed all the analyzing of attachments, this
      # includes the ExcelAnalyzer.on_hidden_metadata callback
      not_analyzed_attachments = incoming_message.foi_attachments.
        joins(:file_blob).
        where("active_storage_blobs.metadata::json->>'analyzed' IS NULL")

      # Or wait 5 minutes if there are hidden attachments, I.E. ones we've
      # hidden due to detecting hidden content which are waiting for the job to
      # run to check for personal identifiable information.
      hidden_attachments = incoming_message.foi_attachments.where(
        prominence: 'hidden',
        prominence_reason: ExcelAnalyzer::PROMINENCE_REASON
      )

      if not_analyzed_attachments.any? || hidden_attachments.any?
        ::RequestMailer.new_response(info_request, incoming_message).
          deliver_later(wait: 5.minutes)

        return
      end

      # No hidden attachments, proceed as normal
      self.action_name = 'new_response'
      super
    end
  end
end
