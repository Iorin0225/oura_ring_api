# frozen_string_literal: true

require "time"

module OuraRingApi
  class OauthHandler # rubocop:todo Style/Documentation
    OAUTH2_SITE   = "https://cloud.ouraring.com"
    OAUTH2_TOKEN_URL = "https://api.ouraring.com/oauth/token"

    attr_accessor :client_id, :client_secret, :redirect_uri, :scopes, :access_token, :refresh_token, :expires_at

    def initialize(client_id:, client_secret:, redirect_uri:, scopes:)
      self.client_id     = client_id
      self.client_secret = client_secret
      self.redirect_uri = redirect_uri
      self.scopes = scopes
    end

    def authenticated?
      return false if access_token.nil?

      true
    end

    def expired?
      !expires_at.nil? && expires_at <= Time.now
    end

    def authorization_url(state:)
      oauth2_client.auth_code.authorize_url(
        redirect_uri: redirect_uri,
        scope: scopes.join(" "),
        state: state
      )
    end

    def fetch_token_from_code(authrorize_code)
      response = oauth2_client.auth_code.get_token(authrorize_code,
                                                   redirect_uri: redirect_uri)
      token_info = token_info_hash(response)
      save_token_info(token_info)

      token_info
    end

    def token_refresh
      return false if refresh_token.nil?

      oauth2_access_token = OAuth2::AccessToken.new(
        oauth2_client,
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
      self.expires_at = parse_expiration(token_info[:expires_at])
    end

    def token_info_hash(response)
      {
        access_token: response.token,
        refresh_token: response.refresh_token,
        expires_at: response.expires_at
      }
    end

    def parse_expiration(value)
      return Time.at(value) if value.is_a?(Numeric)
      return Time.at(value.to_i) if value.to_s.match?(/\A\d+\z/)

      Time.parse(value)
    end
  end
end
