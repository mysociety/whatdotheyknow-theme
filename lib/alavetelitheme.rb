theme_root = Pathname.new(File.dirname(__FILE__)).join('..').cleanpath

class ActionController::Base
  before_action :set_whatdotheyknow_view_paths

  def set_whatdotheyknow_view_paths
    # Can't use the `theme_root` as its scoped to lib/alavetelitheme.rb
    prepend_view_path File.join(File.dirname(__FILE__), "views")
  end

  # Note that set_view_paths is called by Alaveteli from the
  # rescue_action_in_public method, in order that error pages
  # may be themed correctly. Since whatdotheyknow-theme is a
  # primary theme that ought to style error pages, we define
  # this as an alias
  alias set_view_paths set_whatdotheyknow_view_paths
end

# Append individual theme assets to the asset path
loose_theme_assets = lambda do |logical_path, filename|
  filename.start_with?(theme_root.join('app/assets').to_s) &&
    !['.js', '.css', ''].include?(File.extname(logical_path))
end
Rails.application.config.assets.precompile.unshift(loose_theme_assets)

# Append theme manifest to precompile included linked assets first
Rails.application.config.assets.precompile.unshift(%w[theme_manifest.js])

# Prepend the asset directories in this theme to the asset path
Rails.application.config.to_prepare do
  theme_root.glob('app/assets/*').each do |asset_type_path|
    Rails.application.config.assets.paths.unshift(asset_type_path)
  end
end

# Setup importmap for theme JS
Rails::Application.send(:attr_accessor, :theme_importmap)
Rails.application.theme_importmap = Importmap::Map.new.tap do |map|
  importmap_path = theme_root.join('config/importmap.rb')
  map.draw(importmap_path) if File.exist?(importmap_path)
end

# Monkey patch app code
[
  'patch_mailer_paths.rb',
  'controller_patches.rb',
  'model_patches.rb',
  'helper_patches.rb',
  'mailer_patches.rb',
  'analytics_event.rb',
  'help_page_history.rb',
  'pro_account_bans.rb',
  'public_body_questions.rb',
  'school_late_calculator.rb',
  'volunteer_contact_form.rb',
  'data_breach.rb',
  'excel_analyzer.rb',
  'authority_only_response_gatekeeper.rb',
  'raw_email_usage.rb',
  'immigration_detection.rb',
  'user_check_integration.rb'
].each { |patch| require theme_root.join('lib', patch) }

$alaveteli_route_extensions << 'wdtk-routes.rb'

# Tell FastGettext about the theme's translations: look in the theme's
# locale-theme directory for a translation in the first place, and if
# it isn't found, look in the Alaveteli locale directory next:
paths = []
paths << theme_root.join('locale-theme')
paths << 'locale_alaveteli_pro' if AlaveteliConfiguration.enable_alaveteli_pro
paths << 'locale'
repos = paths.map do |path|
  FastGettext::TranslationRepository.build('app', path: path, type: :po)
end
AlaveteliLocalization.set_default_text_domain('app', repos)
