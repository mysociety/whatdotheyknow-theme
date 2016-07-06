# Load our helpers
require 'helpers/user_helper'

Rails.configuration.to_prepare do
  ActionView::Base.send(:include, UserHelper)

  ApplicationHelper.class_eval do
    def is_contact_page?
      controller.controller_name == 'help' && controller.action_name == 'contact'
    end
  end
end
