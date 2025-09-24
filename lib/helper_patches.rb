# Load our helpers
require 'helpers/donation_helper'
require 'helpers/alaveteli_pro/alternative_price_text_helper'

Rails.configuration.to_prepare do
  ActionView::Base.send(:include, DonationHelper)
  ActionView::Base.send(:include, AlaveteliPro::AlternativePriceTextHelper)

  ApplicationHelper.class_eval do
    def is_contact_page?
      controller.controller_name == 'help' && controller.action_name == 'contact'
    end

    def request_url_with_query
      add_query_params_to_url(request.original_url, query: @query)
    end
  end

  AlaveteliPro::BatchRequestAuthoritySearchesHelper.class_eval do
    def new_batch_user?
      current_user.info_request_batches.size < 3
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
end
