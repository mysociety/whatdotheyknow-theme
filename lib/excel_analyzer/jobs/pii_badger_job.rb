require 'external_command'
require 'shellwords'

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

    TIMEOUT = 15.minutes

    def perform(attachment_blob)
      attachment_blob.open(tmpdir: ENV['EXCEL_ANALYZER_TMP_DIR']) do |file|
        started_at = Time.current
        pii_badger_metadata = run_pii_badger(file.path).merge(
          duration: (Time.current - started_at).round(1)
        )

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

    private

    def run_pii_badger(path)
      xc = ExternalCommand.new(
        *Shellwords.split(ENV['EXCEL_ANALYZER_PII_BADGER_COMMAND']),
        '--file', path,
        timeout: TIMEOUT.to_i
      ).run

      return JSON.parse(xc.out) if xc.exited && xc.status == 0

      # ExternalCommand returns binary output, which can't be stored as JSON
      stderr = xc.err.dup.force_encoding(Encoding::UTF_8).scrub
      stderr = stderr.lines.last(10).join
      { error: [failure_reason(xc), stderr].join("\n").strip }
    rescue StandardError => ex
      { error: "#{ex.class}: #{ex.message}" }
    end

    def failure_reason(xc)
      if xc.timed_out
        "Timed out after #{TIMEOUT.inspect}"
      elsif xc.exited
        "Exited with status #{xc.status}"
      else
        'Terminated abnormally'
      end
    end
  end
end
