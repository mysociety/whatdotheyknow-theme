# Load our helpers
require 'helpers/donation_helper'

Rails.configuration.to_prepare do
  ActionView::Base.send(:include, DonationHelper)

  ApplicationHelper.class_eval do
    def is_contact_page?
      controller.controller_name == 'help' && controller.action_name == 'contact'
    end

    def request_url_with_query
      uri = URI.parse(request.original_url);
      uri.query = URI.encode_www_form(
        URI.decode_www_form(String(uri.query)).push(['query', @query])
      );
      uri.to_s
    end
  end

  DatasetteHelper.datasette_url = 'https://data.mysociety.org/datasette/'
end
