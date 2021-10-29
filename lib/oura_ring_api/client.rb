# frozen_string_literal: true

require_relative "services/oauth_helper"
require_relative "responses/userinfo"
require_relative "responses/sleep"
require_relative "responses/activity"
require_relative "responses/readiness"

module OuraRingApi
  class Client
    OURA_API_URL   = "https://api.ouraring.com"
    USERINFO_PATH  = "/v1/userinfo"
    SLEEP_PATH     = "/v1/sleep"
    ACTIVITY_PATH  = "/v1/activity"
    READINESS_PATH = "/v1/readiness"

    def initialize(client_id: nil,
                   client_secret: nil,
                   token_info: nil,
                   personal_access_token: nil)

      @personal_access_token = personal_access_token
      return if use_personal_access_token?

      @oauth_handler = OuraRingApi::OauthHandler.new(client_id, client_secret)
      @oauth_handler.save_token_info(token_info) unless token_info.nil?
    end

    def url_to_generate_code
      @oauth_handler.url_to_generate_code
    end

    def authenticate(code:)
      @oauth_handler.fetch_token_from_code(code)
    end

    def userinfo
      response = request_api(USERINFO_PATH, :get, nil)
      OuraRingApi::Response::Userinfo.new(response)
    end

    def sleep_summary(start_date = nil,
                      end_date = nil)
      params = {
        start: start_date,
        end: end_date
      }
      response = request_api(SLEEP_PATH, :get, params)
      OuraRingApi::Response::Sleep.new(response)
    end

    def activity_summary(start_date = nil,
                         end_date = nil)
      params = {
        start: start_date,
        end: end_date
      }
      response = request_api(ACTIVITY_PATH, :get, params)
      OuraRingApi::Response::Activity.new(response)
    end

    def readiness_summary(start_date = nil,
                          end_date = nil)
      params = {
        start: start_date,
        end: end_date
      }
      response = request_api(READINESS_PATH, :get, params)
      OuraRingApi::Response::Readiness.new(response)
    end

    private

    def request_api(path, method, params)
      response = api_client.send(method) do |req|
        req.url path
        req.params = params unless params.nil?
      end
      case response.status
      when 401
        raise "Unauthorized"
      end
      response
    end

    def api_client
      if use_oauth?
        raise "Not authenticated yet" unless @oauth_handler.authenticated?

        @oauth_handler.token_refresh if @oauth_handler.expired?
      end

      client = Faraday.new(url: OURA_API_URL) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Faraday.default_adapter
      end
      client.authorization :Bearer, access_token
      client
    end

    def access_token
      if use_personal_access_token?
        @personal_access_token
      else
        @oauth_handler.access_token
      end
    end

    def use_personal_access_token?
      !@personal_access_token.nil?
    end

    def use_oauth?
      !use_personal_access_token?
    end
  end
end
