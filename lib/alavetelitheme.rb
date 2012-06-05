require 'routingfilter'

class ActionController::Base
    before_filter :set_whatdotheyknow_view_paths

    def set_whatdotheyknow_view_paths
        self.prepend_view_path File.join(File.dirname(__FILE__), "views")
    end
    
    # Note that set_view_paths is called by Alaveteli from the
    # rescue_action_in_public method, in order that error pages
    # may be themed correctly. Since whatdotheyknow-theme is a
    # primary theme that ought to style error pages, we define
    # this as an alias
    alias :set_view_paths :set_whatdotheyknow_view_paths
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

