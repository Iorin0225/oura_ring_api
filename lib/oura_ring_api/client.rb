# frozen_string_literal: true

require_relative "services/oauth_helper"
require_relative "responses/personal_info"
require_relative "responses/daily_sleep"
require_relative "responses/daily_activity"
require_relative "responses/daily_readiness"
require_relative "responses/sleep"

module OuraRingApi
  class Client
    OURA_API_URL = "https://api.ouraring.com"
    DEFAULT_SCOPES = %w[email personal daily workout tag session].freeze

    PERSONAL_INFO_PATH = "/v2/usercollection/personal_info"
    DAILY_SLEEP_PATH = "/v2/usercollection/daily_sleep"
    SLEEP_PATH = "/v2/usercollection/sleep"
    DAILY_ACTIVITY_PATH = "/v2/usercollection/daily_activity"
    DAILY_READINESS_PATH = "/v2/usercollection/daily_readiness"
    SESSION_PATH = "/v2/usercollection/session"
    TAG_PATH = "/v2/usercollection/tag"
    WORKOUT_PATH = "/v2/usercollection/workout"

    attr_reader :oauth_handler

    def initialize(client_id:, client_secret:, redirect_uri:, token_info: nil, scopes: DEFAULT_SCOPES)
      @oauth_handler = OuraRingApi::OauthHandler.new(
        client_id: client_id,
        client_secret: client_secret,
        redirect_uri: redirect_uri,
        scopes: scopes
      )
      @oauth_handler.save_token_info(token_info) if token_info
    end

    def authorization_url(state:)
      @oauth_handler.authorization_url(state: state)
    end

    def authenticate(code:)
      @oauth_handler.fetch_token_from_code(code)
    end

    def token_info
      {
        access_token: @oauth_handler.access_token,
        refresh_token: @oauth_handler.refresh_token,
        expires_at: @oauth_handler.expires_at.to_i
      }
    end

    def personal_info
      request(:personal_info)
    end

    def daily_sleep(start_date = nil, end_date = nil, document_id: nil, next_token: nil, fields: nil)
      request(:daily_sleep, start_date, end_date, document_id: document_id, next_token: next_token, fields: fields)
    end

    def sleep(start_date = nil, end_date = nil, document_id: nil, next_token: nil, fields: nil)
      request(:sleep, start_date, end_date, document_id: document_id, next_token: next_token, fields: fields)
    end

    def daily_activity(start_date = nil, end_date = nil, document_id: nil, next_token: nil, fields: nil)
      request(:daily_activity, start_date, end_date, document_id: document_id, next_token: next_token, fields: fields)
    end

    def daily_readiness(start_date = nil, end_date = nil, document_id: nil, next_token: nil, fields: nil)
      request(:daily_readiness, start_date, end_date, document_id: document_id, next_token: next_token, fields: fields)
    end

    def session(start_date = nil, end_date = nil, document_id: nil, next_token: nil, fields: nil)
      request(:session, start_date, end_date, document_id: document_id, next_token: next_token, fields: fields)
    end

    def tag(start_date = nil, end_date = nil, document_id: nil, next_token: nil, fields: nil)
      request(:tag, start_date, end_date, document_id: document_id, next_token: next_token, fields: fields)
    end

    def workout(start_date = nil, end_date = nil, document_id: nil, next_token: nil, fields: nil)
      request(:workout, start_date, end_date, document_id: document_id, next_token: next_token, fields: fields)
    end

    def each_page(type, start_date: nil, end_date: nil, fields: nil)
      return enum_for(__method__, type, start_date: start_date, end_date: end_date, fields: fields) unless block_given?

      next_token = nil
      loop do
        page = request(type, start_date, end_date, next_token: next_token, fields: fields)
        yield page
        next_token = page.next_token
        break unless next_token
      end
    end

    def request(type, start_date = nil, end_date = nil, document_id: nil, next_token: nil, fields: nil)
      return request_document(type, document_id: document_id) if document_id

      params = compact_params(start_date: start_date, end_date: end_date, next_token: next_token, fields: fields)
      response_class_by_type(type).new(request_api(path_by_type(type), params))
    end

    def request_document(type, document_id:)
      response_class_by_type(type).new(request_api("#{path_by_type(type)}/#{document_id}"))
    end

    private

    def compact_params(params)
      params.reject { |_key, value| value.nil? }
    end

    def path_by_type(type)
      self.class.const_get("#{type.to_s.upcase}_PATH")
    end

    def response_class_by_type(type)
      OuraRingApi::Response.const_get(type.to_s.split("_").map(&:capitalize).join)
    rescue NameError
      OuraRingApi::Response::Base
    end

    def request_api(path, params = nil, retried: false)
      response = api_client.get(path) { |request| request.params.update(params) if params }
      return response if response.success?

      if response.status == 401 && !retried && @oauth_handler.refresh_token
        @oauth_handler.token_refresh
        return request_api(path, params, retried: true)
      end

      raise HttpError.new(status: response.status, body: response.body, headers: response.headers)
    end

    def api_client
      raise Error, "Not authenticated yet" unless @oauth_handler.authenticated?

      @oauth_handler.token_refresh if @oauth_handler.expired?
      Faraday.new(url: OURA_API_URL) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Faraday.default_adapter
      end.tap { |client| client.request(:authorization, :Bearer, @oauth_handler.access_token) }
    end
  end
end
