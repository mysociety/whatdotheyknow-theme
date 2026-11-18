module ExcelAnalyzer
  ##
  # Previews of the ExcelAnalyzer report email, shown at /rails/mailers.
  #
  class NotifierMailerPreview < ActionMailer::Preview
    def pii_badger_failed
      ExcelAnalyzer::NotifierMailer.report(
        blob(pii_badger: failure), [:pii_badger_failed]
      )
    end

    def potential_pii_leaks
      ExcelAnalyzer::NotifierMailer.report(
        blob(pii_badger: leaks), [:potential_pii_leaks]
      )
    end

    def several_reasons
      ExcelAnalyzer::NotifierMailer.report(
        blob(excel: excel.merge(data_model: 1), pii_badger: leaks),
        [:potential_pii_leaks, :data_model]
      )
    end

    private

    # The metadata is not saved, so the preview does not change the blob
    def blob(**metadata)
      FoiAttachment.joins(:file_blob).last.file_blob.tap do |blob|
        blob.metadata = blob.metadata.merge(excel: excel, **metadata)
      end
    end

    def excel
      {
        data_model: 0, external_links: 0, hidden_columns: 0,
        hidden_rows: 112, hidden_sheets: 0, named_ranges: 1, pivot_cache: 0
      }
    end

    def failure
      {
        duration: 9.6,
        error: <<~ERROR.strip
          Exited with status 1
          ValueError: Unable to read workbook: could not read worksheets from
          /tmp/ActiveStorage-123.xlsx.
        ERROR
      }
    end

    def leaks
      {
        duration: 245.3,
        potential_pii_leaks: [
          { source: 'Pivot Cache', pii_type: 'PERSON', count: 2965,
            average_confidence: 0.8499999999999526 },
          { source: 'Pivot Cache', pii_type: 'UK_PASSPORT_NUMBER', count: 43,
            average_confidence: 0.8999999999999992 }
        ]
      }
    end
  end
end
