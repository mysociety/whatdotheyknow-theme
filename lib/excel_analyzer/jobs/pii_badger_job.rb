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

    attr_reader :attachment_blob, :foi_attachment

    def perform(attachment_blob)
      @attachment_blob = attachment_blob
      @foi_attachment = FoiAttachment.joins(:file_blob).
        find_by(active_storage_blobs: { id: attachment_blob })

      begin
        cmd = [
          ENV['EXCEL_ANALYZER_PII_BADGER_COMMAND'], '--file', file.path
        ].join(' ')

        pii_badger_metadata = IO.popen(cmd) { JSON.parse(_1.read) }

        attachment_blob.update(metadata: attachment_blob.metadata.merge(
          pii_badger: pii_badger_metadata
        ))
      ensure
        file.close!
      end

      ExcelAnalyzer::RepublishOrReportJob.perform_later(attachment_blob)
    end

    private

    def name
      [
        "ActiveStorage-#{attachment_blob.id}-",
        attachment_blob.filename.extension_with_delimiter
      ]
    end

    def file
      @file ||= (
        file = Tempfile.open(name, ENV['EXCEL_ANALYZER_TMP_DIR'])
        file.binmode
        file.write(foi_attachment.unmasked_body)
        file.flush
        file.rewind
        file
      )
    end
  end
end

module ActiveStorage
  class Service::MirrorService
    def download(key)
      primary.download(key)
    rescue ActiveStorage::FileNotFoundError => primary_error
      mirrors.each_with_index do |mirror, index|
        begin
          data = mirror.download(key)
          return data
        rescue ActiveStorage::FileNotFoundError => mirror_error
          next
        end
      end
      raise primary_error
    end
  end
end
