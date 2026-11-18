module ExcelAnalyzer
  class NotifierMailer < ApplicationMailer
    include Rails.application.routes.url_helpers
    default_url_options[:host] = AlaveteliConfiguration.domain

    REASONS = {
      pii_badger_failed: 'PII Badger could not scan this file',
      potential_pii_leaks: 'PII Badger found possible personal data',
      xls_pivot_cache: 'XLS file with a pivot cache',
      external_links: 'Named ranges and external links present',
      data_model: 'Data model present'
    }.freeze

    def report(attachment_blob, reasons)
      @foi_attachment = FoiAttachment.joins(:file_blob).
        find_by(active_storage_blobs: { id: attachment_blob })
      @incoming_message = @foi_attachment.incoming_message
      @metadata = attachment_blob.metadata
      @reasons = REASONS.values_at(*reasons)

      from = email_address_with_name(
        blackhole_email, 'WhatDoTheyKnow.com Excel Analyzer report'
      )

      headers['X-WDTK-Contact'] = 'wdtk-excel-analyzer-report'
      headers['X-WDTK-CaseRef'] = @foi_attachment.id

      mail(
        from: from,
        to: ENV['EXCEL_ANALYZER_NOTIFICATION_EMAIL'],
        subject: _('ExcelAnalyzer: hidden data detected [{{reference}}]',
                   reference: @foi_attachment.id)
      )
    end
  end
end
