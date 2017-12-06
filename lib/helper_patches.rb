# Load our helpers
require 'helpers/user_helper'
require 'helpers/donation_helper'

Rails.configuration.to_prepare do
  ActionView::Base.send(:include, UserHelper)
  ActionView::Base.send(:include, DonationHelper)

  ApplicationHelper.class_eval do
    def is_contact_page?
      controller.controller_name == 'help' && controller.action_name == 'contact'
    end
  end
end
