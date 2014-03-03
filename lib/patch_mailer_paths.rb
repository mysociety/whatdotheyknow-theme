# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do
    # Add theme templates to the mailer templates (not overriding the defaults).
    ActionMailer::Base.prepend_view_path File.join(File.dirname(__FILE__), "views")
end
