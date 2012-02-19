# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
require 'dispatcher'
Dispatcher.to_prepare do
    # Override mailer templates with theme ones.
    ActionMailer::Base.view_paths.unshift File.join(File.dirname(__FILE__), "views")
    ActionMailer::Base.view_paths = ActionView::Base.process_view_paths(ActionMailer::Base.view_paths)
    Rails.logger.debug "view_paths: #{ActionMailer::Base.view_paths.inspect}"
end
