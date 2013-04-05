# Load our helpers
require 'helpers/user_helper'

Rails.configuration.to_prepare do
    ActionView::Base.send(:include, UserHelper)
end
