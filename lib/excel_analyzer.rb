ExcelAnalyzer.on_hidden_metadata = ->(attachment_blob, metadata) do
  foi_attachment = FoiAttachment.joins(:file_blob).
    find_by(active_storage_blobs: { id: attachment_blob })

  incoming_message = foi_attachment.incoming_message
  next if incoming_message.sent_at < 1.day.ago

  foi_attachment.update_and_log_event(
    prominence: 'hidden',
    event: {
      editor: User.internal_admin_user,
      reason: 'ExcelAnalyzer: hidden data dectected'
    }
  )

  ExcelAnalyzerNotifier.report(foi_attachment, metadata).deliver_now
end

Rails.configuration.to_prepare do
  class ExcelAnalyzerNotifier < ApplicationMailer
    include Rails.application.routes.url_helpers
    default_url_options[:host] = AlaveteliConfiguration.domain

    def report(foi_attachment, metadata)
      @foi_attachment = foi_attachment
      @metadata = metadata

      from = email_address_with_name(
        blackhole_email, 'WhatDoTheyKnow.com Execl Analyzer report'
      )

      headers['X-WDTK-Contact'] = 'wdtk-excel-anaylzer-report'
      headers['X-WDTK-CaseRef'] = @foi_attachment.id

      mail(
        from: from,
        to: pro_contact_from_name_and_email,
        subject: _('ExcelAnalyzer: hidden data detected [{{reference}}]',
                   reference: @foi_attachment.id)
      )
    end
  end
end
