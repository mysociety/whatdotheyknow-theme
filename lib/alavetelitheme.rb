require 'routingfilter'

class ActionController::Base
    before_filter :set_view_paths

    def set_view_paths
        self.prepend_view_path File.join(File.dirname(__FILE__), "views")
    end
end

# In order to have the theme lib/ folder ahead of the main app one,
# inspired in Ruby Guides explanation: http://guides.rubyonrails.org/plugins.html
%w{ . }.each do |dir|
  path = File.join(File.dirname(__FILE__), dir)
  $LOAD_PATH.insert(0, path)
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end

# Monkey patch app code
require 'controller_patches.rb'
require 'model_patches.rb'
require 'helper_patches.rb'
require 'patch_mailer_paths.rb'

# Extend routes
require 'config/custom-routes.rb'

# Plug theme-specific locale strings
require 'gettext_setup.rb'
