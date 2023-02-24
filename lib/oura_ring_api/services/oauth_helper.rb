# frozen_string_literal: true

module OuraRingApi
  class OauthHandler # rubocop:todo Style/Documentation
    CALLBACK_URL  = "http://localhost:8080"
    OAUTH2_SITE   = "https://cloud.ouraring.com"
    OAUTH2_URL    = "#{OAUTH2_SITE}/oauth/authorize".freeze
    OAUTH2_TOKEN_URL = "https://api.ouraring.com/oauth/token"

    attr_accessor :client_id, :client_secret, :access_token, :refresh_token, :expires_at

    def initialize(client_id = nil, client_secret = nil)
      self.client_id     = client_id
      self.client_secret = client_secret
    end

    def authenticated?
      return false if access_token.nil?

      true
    end

    def expired?
      !expires_at.nil? && expires_at <= Time.now
    end

    def url_to_generate_code
      "#{OAUTH2_URL}?client_id=#{client_id}&redirect_uri=#{CALLBACK_URL}&response_type=code"
    end

    def fetch_token_from_code(authrorize_code)
      response = oauth2_client.auth_code.get_token(authrorize_code,
                                                   redirect_uri: CALLBACK_URL)
      token_info = token_info_hash(response)
      save_token_info(token_info)

      token_info
    end

    def token_refresh
      return false if refresh_token.nil?

      oauth2_access_token = OAuth2::AccessToken.new(
        client,
        access_token,
        refresh_token: refresh_token,
        expires_at: expires_at.to_i
      )
      response = oauth2_access_token.refresh!

      token_info = token_info_hash(response)
      save_token_info(token_info)

      token_info
    end

    def oauth2_client
      @oauth2_client ||= OAuth2::Client.new(
        client_id,
        client_secret,
        site: OAUTH2_SITE,
        token_url: OAUTH2_TOKEN_URL
      )
    end

    def save_token_info(token_info)
      self.access_token = token_info[:access_token]
      self.refresh_token = token_info[:refresh_token]
      self.expires_at = Time.parse(token_info[:expires_at])
    end

    def token_info_hash(response)
      {
        access_token: response.token,
        refresh_token: response.refresh_token,
        expires_at: Time.at(response.expires_at).strftime("%Y-%m-%d %H:%M:%S")
      }
    end
  end
end
