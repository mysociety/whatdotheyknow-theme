require 'routingfilter'

class ActionController::Base
    before_action :set_whatdotheyknow_view_paths

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

# Append individual theme assets to the asset path
theme_asset_path = File.join(File.dirname(__FILE__),
                             '..',
                             'app',
                             'assets')
theme_asset_path = Pathname.new(theme_asset_path).cleanpath.to_s

LOOSE_THEME_ASSETS = lambda do |logical_path, filename|
  filename.start_with?(theme_asset_path) &&
  !['.js', '.css', ''].include?(File.extname(logical_path))
end

Rails.application.config.assets.precompile.unshift(LOOSE_THEME_ASSETS)

Rails.application.config.assets.precompile << ["tests.js"]

def prepend_theme_assets
  # Prepend the asset directories in this theme to the asset path:
  ['stylesheets', 'images', 'javascripts'].each do |asset_type|
      theme_asset_path = File.join(File.dirname(__FILE__),
                                   '..',
                                   'app',
                                   'assets',
                                   asset_type)
      Rails.application.config.assets.paths.unshift theme_asset_path
  end
end

Rails.application.config.to_prepare do
  prepend_theme_assets
end

# Monkey patch app code
for patch in ['patch_mailer_paths.rb',
              'controller_patches.rb',
              'model_patches.rb',
              'helper_patches.rb',
              'mailer_patches.rb',
              'analytics_event.rb',
              'help_page_history.rb',
              'public_body_questions.rb',
              'school_late_calculator.rb',
              'volunteer_contact_form.rb']
    require File.expand_path "../#{patch}", __FILE__
end

$alaveteli_route_extensions << 'wdtk-routes.rb'

# Tell FastGettext about the theme's translations: look in the theme's
# locale-theme directory for a translation in the first place, and if
# it isn't found, look in the Alaveteli locale directory next:
paths = []
paths << File.join(File.dirname(__FILE__), '..', 'locale-theme')
paths << 'locale_alaveteli_pro' if AlaveteliConfiguration::enable_alaveteli_pro
paths << 'locale'
repos = paths.map do |path|
  FastGettext::TranslationRepository.build('app', :path => path, :type => :po)
end
AlaveteliLocalization.set_default_text_domain('app', repos)
