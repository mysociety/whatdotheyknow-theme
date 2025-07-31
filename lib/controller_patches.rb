# Please arrange overridden classes alphabetically.
Rails.application.config.after_initialize do
  class LearnController < ApplicationController
    def index; end
    def understanding_rights; end
    def how_to_make_requests; end
    def effective_requests; end
    def privacy_anonymity; end
    def request_refused_delayed; end
    def foi_myths; end
  end
  class RulesController < ApplicationController
    def welcome; end
  end
end

Rails.configuration.to_prepare do
  AdminCensorRuleController.class_eval do
    before_action :block_global_censor_rule_creation, only: [:create]

    private

    def block_global_censor_rule_creation
      raise NotImplementedError if @censor_rule.is_global?
    end
  end

  HelpController.class_eval do
    prepend VolunteerContactForm::ControllerMethods
    prepend DataBreach::ControllerMethods

    before_action :set_history, except: [:index, :report_a_data_breach_handle_form_submission]

    def principles; end
    def house_rules; end
    def how; end
    def complaints; end
    def volunteers; end
    def beginners; end
    def ico_officers; end
    def glossary; end
    def environmental_information; end
    def accessing_information; end
    def exemptions; end
    def authority_performance_tracking; end
    def search_engines; end
    def about_foi; end
    def about_foisa; end
    def no_response; end
    def appeals; end
    def removing_information; end
    def books; end
    def commercial_interests_exemptions; end

    private

    def set_history
      @history ||= HelpPageHistory.new(
        lookup_context.find_template("#{controller_path}/#{action_name}")
      )
    end

    def set_recaptcha_required
      @recaptcha_required =
        AlaveteliConfiguration.contact_form_recaptcha &&
        request_from_foreign_country?
    end

    def request_from_foreign_country?
      country_from_ip != AlaveteliConfiguration.iso_country_code
    end
  end

  RequestController.class_eval do
    before_action :check_spam_terms, only: [:new]

    def check_spam_terms
      return true unless params[:outgoing_message]
      return true unless params[:outgoing_message][:body]

      if spammer?(params[:outgoing_message][:body])
        # if they're signed in, ban them and redirect them to their profile
        # so that they can see they've been banned
        # otherwise, just prevent the form submission
        if @user
          msg = "Blocked user for use of spam terms, " \
                "email: #{@user.email}, " \
                "name: '#{@user.name}'"
          Rails.logger.warn(msg)

          @user.update!(ban_text: 'Account closed', closed_at: Time.zone.now)
          clear_session_credentials
          redirect_to show_user_path(@user.url_name)
        else
          msg = "Prevented unauthenticated user submitting spam term."
          Rails.logger.warn(msg)

          redirect_to root_path
          true
        end
      else
        true
      end
    end

    def spammer?(text)
      return false unless spam_terms.any?
      # https://stackoverflow.com/a/43278823/387558
      # String#match? is Ruby 2.4.0 only so need to tweak
      # Need to make a case-insensitive regexp for each term then join them all
      # together
      text =~ Regexp.union(spam_terms.map { |t| Regexp.new(/#{t}/i) })
    end

    def spam_terms
      config = Rails.root + 'tmp/spam_terms.txt'
      if File.exist?(config)
        File.read(config).split("\n")
      else
        []
      end
    end
  end

  Users::MessagesController.class_eval do
    private

    def set_recaptcha_required
      @recaptcha_required =
        AlaveteliConfiguration.user_contact_form_recaptcha &&
        request_from_foreign_country?
    end

    def request_from_foreign_country?
      country_from_ip != AlaveteliConfiguration.iso_country_code
    end
  end
end
