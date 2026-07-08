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

  class MapAreasController < ApplicationController
    MAPIT_BASE_URL = 'https://mapit.mysociety.org'.freeze

    def show
      geojson = cached_geojson(params[:id])

      if geojson
        expires_in 1.week, public: true
        render json: geojson, content_type: 'application/json'
      else
        head :bad_gateway
      end
    end

    private

    def cached_geojson(area_id)
      cache_key = "mapit_area_geojson/#{area_id}"

      cached = Rails.cache.read(cache_key)
      return (cached == :unavailable ? nil : cached) if cached

      geojson = fetch_geojson(area_id)

      if geojson
        Rails.cache.write(cache_key, geojson, expires_in: 1.month)
      else
        # Cache failures briefly so an unresponsive MapIt doesn't tie up
        # app workers on every map view
        Rails.cache.write(cache_key, :unavailable, expires_in: 5.minutes)
      end

      geojson
    end

    def fetch_geojson(area_id)
      uri = URI.parse(
        "#{MAPIT_BASE_URL}/area/#{area_id}.geojson?simplify_tolerance=0.0001"
      )

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10

      user_agent = "Alaveteli MapIt proxy (#{AlaveteliConfiguration.domain})"
      response = http.get(uri.request_uri, 'User-Agent' => user_agent)
      return unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body) # check MapIt sent valid JSON before we cache it
      response.body
    rescue JSON::ParserError, Timeout::Error, SocketError, SystemCallError,
           OpenSSL::SSL::SSLError
      nil
    end
  end

  class RulesController < ApplicationController
    def welcome; end
  end
end

Rails.configuration.to_prepare do
  Admin::CensorRulesController.class_eval do
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
      AlaveteliSpamTermChecker.new.spam?(text)
    end
  end

  Users::ConfirmationsController.class_eval do
    module RulesConfirmation
      def confirm
        if !@force_confirm && post_redirect.circumstance == 'normal'
          session[:post_redirect_token] = post_redirect.token
          redirect_to(welcome_path) && return
        end

        super
      end

      def force_confirm
        @force_confirm = true
        confirm
      end

      private

      def post_redirect
        @post_redirect ||= (
          if params[:email_token]
            PostRedirect.find_by(email_token: params[:email_token])
          else
            PostRedirect.find_by(token: session[:post_redirect_token])
          end
        )
      end
    end

    prepend RulesConfirmation
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
