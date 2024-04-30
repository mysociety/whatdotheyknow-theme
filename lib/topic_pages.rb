Rails.configuration.after_initialize do
  feature_keys = AlaveteliFeatures.features.all.map(&:key)

  AlaveteliFeatures.features.add(
    :wdtk_topic_pages,
    label: 'Browse request topic pages'
  ) unless feature_keys.include?(:wdtk_topic_pages)
end
