module ProAccountBans
  module ModelMethods
    PRO_ACCOUNT_BANS_CONFIG = Rails.root.join('config/pro_account_bans.yml')

    def update_source
      return super unless pro_account_banned?

      raise ProAccount::CardError, _("The card issuer couldn't authorize " \
                                     "payment.")
    end

    def pro_account_banned?
      return false unless bans_config

      bans_config.any? do |ban|
        ban.all? do |k, banned_value|
          value = @token.card[k]
          value.upcase.gsub(/\S/, '') if k == 'address_key'
          value == banned_value
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
