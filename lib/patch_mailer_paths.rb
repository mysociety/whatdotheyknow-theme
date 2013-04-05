# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do
    # Add theme templates to the mailer templates (not overriding the defaults).
    ActionMailer::Base.view_paths << File.join(File.dirname(__FILE__), "views")
    Rails.logger.debug "patch_mailer_paths.rb: view_paths = #{ActionMailer::Base.view_paths.inspect}"
end
