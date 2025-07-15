require_relative 'spec_helper'
require 'webmock/rspec'

RSpec.describe UserCheckIntegration do
  let(:api_key) { 'test_api_key_123' }
  let(:test_domain) { 'example.com' }
  let(:disposable_domain) { 'tempmail.com' }

  before do
    WebMock.disable_net_connect!
    described_class.api_key = api_key
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  after do
    WebMock.allow_net_connect!
    described_class.api_key = nil
    Rails.cache = @original_cache
  end

  describe '.api_key' do
    context 'when API key is set via environment variable' do
      before do
        ENV['USERCHECK_API_KEY'] = 'env_api_key'
        described_class.instance_variable_set(:@api_key, nil)
      end

      after do
        ENV.delete('USERCHECK_API_KEY')
      end

      it 'returns the environment variable value' do
        expect(described_class.api_key).to eq('env_api_key')
      end
    end

    context 'when API key is set directly' do
      it 'returns the set API key' do
        described_class.api_key = 'direct_api_key'
        expect(described_class.api_key).to eq('direct_api_key')
      end
    end
  end

  describe '.api_key=' do
    it 'sets the API key' do
      described_class.api_key = 'new_key'
      expect(described_class.api_key).to eq('new_key')
    end
  end

  describe '.enabled?' do
    context 'when API key is present' do
      before { described_class.api_key = 'test_key' }

      it 'returns true' do
        expect(described_class).to be_enabled
      end
    end

    context 'when API key is nil' do
      before do
        ENV.delete('USERCHECK_API_KEY')
        described_class.api_key = nil
      end

      it 'returns false' do
        expect(described_class).not_to be_enabled
      end
    end

    context 'when API key is empty string' do
      before { described_class.api_key = '' }

      it 'returns false' do
        expect(described_class).not_to be_enabled
      end
    end
  end

  describe '.check_domain' do
    context 'when integration is disabled' do
      before do
        allow(described_class).to receive(:enabled?).and_return(false)
      end

      it 'returns default safe values' do
        result = described_class.check_domain(test_domain)
        expect(result).to eq({ disposable: false })
      end

      it 'does not make API requests' do
        described_class.check_domain(test_domain)
        expect(WebMock).not_to have_requested(:get, /api\.usercheck\.com/)
      end
    end

    context 'when integration is enabled' do
      let(:api_url) { "https://api.usercheck.com/domain/#{test_domain}" }

      context 'with successful API response' do
        let(:api_response) do
          {
            'disposable' => false,
            'mx' => true,
            'status' => 200
          }
        end

        before do
          stub_request(:get, api_url).
            with(headers: {
                   'Authorization' => "Bearer #{api_key}",
                   'Content-Type' => 'application/json'
                 }).
            to_return(status: 200, body: api_response.to_json)
        end

        it 'returns parsed response data' do
          result = described_class.check_domain(test_domain)
          expect(result).to include(
            success: true,
            disposable: false,
            mx_valid: true,
            raw_data: api_response
          )
        end

        it 'caches the result' do
          described_class.check_domain(test_domain)
          described_class.check_domain(test_domain)
          expect(WebMock).to have_requested(:get, api_url).once
        end

        it 'uses cached result on subsequent calls' do
          first_result = described_class.check_domain(test_domain)
          second_result = described_class.check_domain(test_domain)
          expect(first_result).to eq(second_result)
        end
      end

      context 'with disposable domain response' do
        let(:api_response) do
          {
            'disposable' => true,
            'mx' => true,
            'status' => 200
          }
        end

        before do
          stub_request(
            :get, "https://api.usercheck.com/domain/#{disposable_domain}"
          ).to_return(status: 200, body: api_response.to_json)
        end

        it 'correctly identifies disposable domains' do
          result = described_class.check_domain(disposable_domain)
          expect(result).to include(
            success: true,
            disposable: true,
            mx_valid: true,
            raw_data: api_response
          )
        end
      end

      context 'with invalid MX records' do
        let(:api_response) do
          {
            'disposable' => false,
            'mx' => false,
            'status' => 200
          }
        end

        before do
          stub_request(:get, api_url).
            to_return(status: 200, body: api_response.to_json)
        end

        it 'correctly identifies invalid MX records' do
          result = described_class.check_domain(test_domain)
          expect(result).to include(
            success: true,
            disposable: false,
            mx_valid: false,
            raw_data: api_response
          )
        end
      end

      context 'with 401 Unauthorized response' do
        before do
          stub_request(:get, api_url).
            to_return(status: 401, body: '{"error": "Invalid API key"}')
        end

        it 'returns error result' do
          result = described_class.check_domain(test_domain)
          expect(result).to include(
            success: false,
            error: 'Invalid API key'
          )
        end

        it 'logs error message' do
          expect(Rails.logger).to receive(:error).
            with("UserCheck API: Invalid API key")
          described_class.check_domain(test_domain)
        end

        it 'does not cache failed results' do
          described_class.check_domain(test_domain)
          cache_key = "usercheck_domain_#{test_domain}"
          expect(Rails.cache.read(cache_key)).to be_nil
        end
      end

      context 'with 429 Rate Limit response' do
        before do
          stub_request(:get, api_url).
            to_return(status: 429, body: '{"error": "Rate limit exceeded"}')
        end

        it 'returns error result' do
          result = described_class.check_domain(test_domain)
          expect(result).to include(
            success: false,
            error: 'Rate limit exceeded'
          )
        end

        it 'logs warning message' do
          expect(Rails.logger).to receive(:warn).
            with("UserCheck API: Rate limit exceeded")
          described_class.check_domain(test_domain)
        end
      end

      context 'with other HTTP error responses' do
        before do
          stub_request(:get, api_url).
            to_return(status: 500, body: '{"error": "Internal server error"}')
        end

        it 'returns error result with HTTP code' do
          result = described_class.check_domain(test_domain)
          expect(result).to include(
            success: false,
            error: 'HTTP 500'
          )
        end

        it 'logs warning message' do
          expect(Rails.logger).to receive(:warn).
            with("UserCheck API: Unexpected response 500")
          described_class.check_domain(test_domain)
        end
      end

      context 'with timeout error' do
        before do
          stub_request(:get, api_url).
            to_timeout
        end

        it 'returns timeout error result' do
          result = described_class.check_domain(test_domain)
          expect(result).to include(
            success: false,
            error: 'Timeout'
          )
        end

        it 'logs warning message' do
          expect(Rails.logger).to receive(:warn).with(/UserCheck API: Timeout:/)
          described_class.check_domain(test_domain)
        end
      end

      context 'with invalid JSON response' do
        before do
          stub_request(:get, api_url).
            to_return(status: 200, body: 'invalid json')
        end

        it 'returns JSON parsing error result' do
          result = described_class.check_domain(test_domain)
          expect(result).to include(
            success: false,
            error: 'Invalid JSON response'
          )
        end

        it 'logs error message' do
          expect(Rails.logger).to receive(:error).
            with(/UserCheck API: Invalid JSON response:/)
          described_class.check_domain(test_domain)
        end
      end

      context 'with network error' do
        before do
          stub_request(:get, api_url).
            to_raise(SocketError.new('Network error'))
        end

        it 'returns network error result' do
          result = described_class.check_domain(test_domain)
          expect(result).to include(
            success: false,
            error: 'Network error'
          )
        end

        it 'logs error message' do
          expect(Rails.logger).to receive(:error).
            with(/UserCheck API: Unexpected error:/)
          described_class.check_domain(test_domain)
        end
      end

      context 'with SSL error' do
        before do
          stub_request(:get, api_url).
            to_raise(OpenSSL::SSL::SSLError.new('SSL error'))
        end

        it 'returns SSL error result' do
          result = described_class.check_domain(test_domain)
          expect(result).to include(
            success: false,
            error: 'SSL error'
          )
        end
      end
    end
  end

  describe 'constants' do
    it 'defines correct API base URL' do
      expect(UserCheckIntegration::API_BASE_URL).
        to eq('https://api.usercheck.com')
    end

    it 'defines reasonable request timeout' do
      expect(UserCheckIntegration::REQUEST_TIMEOUT).to eq(5.seconds)
    end

    it 'defines reasonable cache duration' do
      expect(UserCheckIntegration::CACHE_DURATION).to eq(28.days)
    end
  end
end
