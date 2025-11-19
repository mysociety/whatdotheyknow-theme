##
# Email address variations detection
#
# Plus email addressing allows users to create variations of their email
# by adding a + and additional text before the @ symbol. For example:
# - foo@gmail.com (base email)
# - foo+bar@gmail.com (variation)
# - foo+spam@gmail.com (another variation)
#
module UserEmailVariations
  extend ActiveSupport::Concern

  def plus_email_variations
    local_part, domain = email.split('@', 2)
    base_local_part = local_part.split('+', 2).first

    # Escape SQL wildcards in the base_local_part to prevent injection
    escaped_base = base_local_part.gsub(/[%_\\]/) { |char| "\\#{char}" }

    User.where('email ILIKE ? ESCAPE ?', "#{escaped_base}+%@#{domain}", '\\')
      .or(User.where('email ILIKE ? ESCAPE ?', "#{escaped_base}@#{domain}", '\\'))
      .where.not('email ILIKE ?', email)
  end

  def all_email_variations
    User.where('email ILIKE ?', email).
      or(plus_email_variations).
      pluck(:email).uniq
  end
end

Rails.configuration.to_prepare do
  User.prepend UserEmailVariations
end

Rails.application.config.after_initialize do
  UserSpamScorer.register_custom_scoring_method(
    :email_variations_tier1,
    1, # Tier 1: First variation
    proc do |user|
      user.all_email_variations.count > 1
    end
  )

  UserSpamScorer.register_custom_scoring_method(
    :email_variations_tier2,
    5, # Tier 2: Multiple variations
    proc do |user|
      user.all_email_variations.count > 3
    end
  )

  UserSpamScorer.register_custom_scoring_method(
    :email_variations_tier3,
    10, # Tier 3: Heavy abuse
    proc do |user|
      user.all_email_variations.count > 6
    end
  )

  UserSpamScorer.register_custom_scoring_method(
    :email_variations_tier4,
    20, # Tier 4: Extreme abuse
    proc do |user|
      user.all_email_variations.count > 10
    end
  )
end
