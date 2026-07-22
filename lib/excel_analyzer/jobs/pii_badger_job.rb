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
      attachment_blob.open(tmpdir: ENV['EXCEL_ANALYZER_TMP_DIR']) do |file|
        cmd = [
          ENV['EXCEL_ANALYZER_PII_BADGER_COMMAND'], '--file', file.path
        ].join(' ')

        pii_badger_metadata = IO.popen(cmd) { JSON.parse(_1.read) }

        # Lock and reload before merging so the analyzer's :excel metadata,
        # which ActiveStorage persists concurrently, is not clobbered by a
        # stale in-memory copy.
        attachment_blob.with_lock do
          attachment_blob.update(metadata: attachment_blob.metadata.merge(
            pii_badger: pii_badger_metadata
          ))
        end
      end

      ExcelAnalyzer::RepublishOrReportJob.perform_later(attachment_blob)
    end
  end
end
