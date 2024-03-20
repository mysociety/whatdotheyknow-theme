module ProAccountBans
  module ModelMethods
    PRO_ACCOUNT_BANS_CONFIG = Rails.root.join('config/pro_account_bans.yml')

    def update_source
      return super unless pro_account_banned?

      sleep (4...10).to_a.sample unless Rails.env.test? # simulate random delay
      raise ProAccount::CardError, _("The card issuer couldn't authorize " \
                                     "payment.")
    end

    def pro_account_banned?
      return false unless bans_config && @token

      bans_config.any? do |ban|
        ban.all? do |k, banned_value|
          value = @token.card[k]
          return unless value

          if k.to_sym == :address_zip
            value.gsub!(/\s/, '')
            banned_value.gsub!(/\s/, '')
          end

          value.upcase == banned_value.upcase
        end
      end
    end

    private

    def bans_config
      return unless File.exist?(PRO_ACCOUNT_BANS_CONFIG)
      YAML.load_file(PRO_ACCOUNT_BANS_CONFIG)
    end
  end
end
