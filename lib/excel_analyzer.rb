Rails.application.config.before_initialize do
  loader = Rails.autoloaders.main

  Dir[File.join(File.dirname(__FILE__), 'excel_analyzer', '**/')].each do
    loader.push_dir(_1, namespace: ExcelAnalyzer)
  end

  loader.inflector.inflect("pii_badger_job" => "PIIBadgerJob")
end

ExcelAnalyzer::PROMINENCE_REASON = "We've found a problem with this file, so " \
  "it's been hidden while we review it. We won't be able to give more " \
  "details until then."

ExcelAnalyzer.on_hidden_metadata = ->(attachment_blob, _) do
  foi_attachment = FoiAttachment.joins(:file_blob).
    find_by(active_storage_blobs: { id: attachment_blob })

  incoming_message = foi_attachment.incoming_message
  next if incoming_message.sent_at < 1.day.ago

  foi_attachment.update_and_log_event(
    prominence: 'hidden',
    prominence_reason: ExcelAnalyzer::PROMINENCE_REASON,
    event: {
      editor: User.internal_admin_user,
      reason: 'ExcelAnalyzer: hidden data detected'
    }
  )

  ExcelAnalyzer::PIIBadgerJob.perform_later(attachment_blob)
end
