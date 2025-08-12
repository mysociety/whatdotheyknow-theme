##
# UserCheck.com Integration for Alaveteli UserSpamScorer
# This module provides integration with the UserCheck.com API for email domain
# validation
#
# Usage:
#   1. Configure your UserCheck.com API key in your application settings
#   2. Require this file in your theme initialization
#   3. The integration will automatically register custom scoring methods
#
# Configuration:
#   Set USERCHECK_API_KEY environment variable
module UserCheck
  API_BASE_URL = 'https://api.usercheck.com'
  REQUEST_TIMEOUT = 5.seconds
  CACHE_DURATION = 28.days

  class << self
    def api_key
      @api_key ||= ENV['USERCHECK_API_KEY']
    end

    attr_writer :api_key

    def enabled?
      api_key.present?
    end

    def check_domain(domain)
      return { disposable: false } unless enabled?

      cache_key = "usercheck_domain_#{domain}"
      cached_result = Rails.cache.read(cache_key)
      return cached_result if cached_result

      result = make_api_request(domain)

      if result[:success]
        Rails.cache.write(cache_key, result, expires_in: CACHE_DURATION)
      end

      result
    end

    private

    def make_api_request(domain)
      uri = URI("#{API_BASE_URL}/domain/#{domain}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = REQUEST_TIMEOUT
      http.open_timeout = REQUEST_TIMEOUT

      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{api_key}"
      request['Content-Type'] = 'application/json'

      response = http.request(request)

      case response.code
      when '200'
        data = JSON.parse(response.body)
        {
          success: true,
          disposable: data['disposable'] == true,
          mx_valid: data['mx'] == true,
          raw_data: data
        }
      when '401'
        Rails.logger.error "UserCheck API: Invalid API key"
        { success: false, error: 'Invalid API key' }
      when '429'
        Rails.logger.warn "UserCheck API: Rate limit exceeded"
        { success: false, error: 'Rate limit exceeded' }
      else
        Rails.logger.warn "UserCheck API: Unexpected response #{response.code}"
        { success: false, error: "HTTP #{response.code}" }
      end

    rescue Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.warn "UserCheck API: Timeout: #{e.message}"
      { success: false, error: 'Timeout' }
    rescue JSON::ParserError => e
      Rails.logger.error "UserCheck API: Invalid JSON response: #{e.message}"
      { success: false, error: 'Invalid JSON response' }
    rescue => e
      Rails.logger.error "UserCheck API: Unexpected error: #{e.message}"
      { success: false, error: e.message }
    end
  end

  module User
    extend ActiveSupport::Concern

    def content_limit(content)
      return 1 if has_tag?('disposable_email')

      super
    end
  end
end

Rails.configuration.to_prepare do
  User.prepend UserCheck::User
end

Rails.application.config.after_initialize do
  if UserCheck.enabled?
    # Check if domain is disposable/temporary
    UserSpamScorer.register_custom_scoring_method(
      :email_domain_is_disposable,
      8, # High score for disposable emails
      proc do |user|
        result = UserCheck.check_domain(user.email_domain)
        result[:success] && result[:disposable]
      end
    )

    # Check if domain has invalid MX records
    UserSpamScorer.register_custom_scoring_method(
      :email_domain_invalid_mx,
      3, # Lower score for MX issues (might be temporary)
      proc do |user|
        result = UserCheck.check_domain(user.email_domain)
        result[:success] && result[:mx_valid] == false
      end
    )
  end
end
