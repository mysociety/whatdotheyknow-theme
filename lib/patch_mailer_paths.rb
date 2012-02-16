# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
require 'dispatcher'
Dispatcher.to_prepare do
    # See http://www.quirkey.com/blog/2008/08/28/actionmailer-hacking-multiple-template-paths/
    # and #comment-59867 thereon.
    ActionMailer::Base.class_eval do
        class_inheritable_accessor :view_paths
    
        def self.prepend_view_path(path)
          if view_paths[0] != path
              self.view_paths = [path] + self.view_paths
          end
        end

        def self.append_view_path(path)
          if view_paths[-1] != path
              self.view_paths = self.view_paths + [path]
          end
        end

        def view_paths
          self.class.view_paths
        end

        private
        def self.view_paths
          @@view_paths||=ActionController::Base.view_paths
        end
    
        def initialize_template_class_without_helper(assigns)
          template = ActionView::Base.new(view_paths, assigns, self)
          template.template_format = default_template_format
          template
        end

    end
    
    # Override mailer templates with theme ones.
    ActionMailer::Base.prepend_view_path File.join(File.dirname(__FILE__), "views")
    Rails.logger.debug "view_paths: #{ActionMailer::Base.view_paths.inspect}"
end
