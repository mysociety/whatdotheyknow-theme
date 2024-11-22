# Load our helpers
require 'helpers/donation_helper'

Rails.configuration.to_prepare do
  ActionView::Base.send(:include, DonationHelper)

  ApplicationHelper.class_eval do
    def is_contact_page?
      controller.controller_name == 'help' && controller.action_name == 'contact'
    end

    def request_url_with_query
      add_query_params_to_url(request.original_url, query: @query)
    end
  end

  DatasetteHelper.datasette_url = 'https://data.mysociety.org/datasette/'

  ProminenceHelper::Base.class_eval do
    module ExcelAnalyzerDisableContactUs
      def contact_us
        return if hidden_by_excel_analyzer?
        super
      end

      def hidden_by_excel_analyzer?
        prominenceable.prominence == 'hidden' &&
          prominenceable.prominence_reason == ExcelAnalyzer::PROMINENCE_REASON
      end
    end

    prepend ExcelAnalyzerDisableContactUs
  end

  AlaveteliPro::PriceHelper.class_eval do
    module AlternativePriceText
      def short_alternative_price_text(price)
        amount = format_currency(
          price.unit_amount_with_tax, no_cents_if_whole: true
        )

        if interval(price) == 'day' && interval_count(price) == 1
          _('or {{amount}} daily', amount: amount)
        elsif interval(price) == 'week' && interval_count(price) == 1
          _('or {{amount}} weekly', amount: amount)
        elsif interval(price) == 'month' && interval_count(price) == 1
          _('or {{amount}} monthly', amount: amount)
        elsif interval(price) == 'year' && interval_count(price) == 1
          _('or {{amount}} annually', amount: amount)
        else
          _('or {{amount}} every {{interval}}',
            amount: amount,
            interval: pluralize_interval(price))
        end
      end
    end

    prepend AlternativePriceText
  end
end
