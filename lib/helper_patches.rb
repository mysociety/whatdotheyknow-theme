# Load our helpers
require 'helpers/user_helper'

require 'dispatcher'
Dispatcher.to_prepare do
    ActionView::Base.send(:include, UserHelper)
end
