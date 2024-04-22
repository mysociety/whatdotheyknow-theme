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
end
