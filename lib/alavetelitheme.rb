require 'routingfilter'

class ActionController::Base
    before_filter :set_whatdotheyknow_view_paths

    def set_whatdotheyknow_view_paths
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
for patch in ['patch_mailer_paths.rb',
              'controller_patches.rb',
              'model_patches.rb',
              'helper_patches.rb',
              'config/custom-routes.rb',
              'gettext_setup.rb',
              'controller_patches.rb']
    require File.expand_path "../#{patch}", __FILE__
end

