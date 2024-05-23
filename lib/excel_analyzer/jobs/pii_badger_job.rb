##
# Job to run additional Personally Identifiable Information (PII) checks on
# files stored as ActiveStorage::Blob
#
# Examples:
#   ExcelAnalyzer::PIIBadgerJob.perform(ActiveStorage::Blob.first)
#
module ExcelAnalyzer
  class PIIBadgerJob < ApplicationJob
    queue_as :excel_analyzer

    def perform(attachment_blob)
      foi_attachment = FoiAttachment.joins(:file_blob).
        find_by(active_storage_blobs: { id: attachment_blob })

      attachment_blob.open(tmpdir: ENV['EXCEL_ANALYZER_TMP_DIR']) do |file|
        cmd = [
          ENV['EXCEL_ANALYZER_PII_BADGER_COMMAND'], '--file', file.path
        ].join(' ')

        pii_badger_metadata = IO.popen(cmd) { JSON.parse(_1.read) }

        attachment_blob.update(metadata: attachment_blob.metadata.merge(
          pii_badger: pii_badger_metadata
        ))
      end

      ExcelAnalyzer::NotifierMailer.report(
        foi_attachment, attachment_blob.metadata[:excel]
      ).deliver_now
    end
  end
end
