# frozen_string_literal: true

require_relative "services/oauth_helper"

# Load all under responses

require_relative "responses/v1/userinfo"
require_relative "responses/v1/sleep"
require_relative "responses/v1/activity"
require_relative "responses/v1/readiness"
require_relative "responses/v1/bedtime"

require_relative "responses/personal_info"
require_relative "responses/daily_sleep"
require_relative "responses/daily_activity"
require_relative "responses/daily_readiness"
require_relative "responses/sleep"

module OuraRingApi
  class Client # rubocop:todo Style/Documentation
    OURA_API_URL = "https://api.ouraring.com"

    V1_USERINFO_PATH  = "/v1/userinfo"
    V1_SLEEP_PATH     = "/v1/sleep"
    V1_ACTIVITY_PATH  = "/v1/activity"
    V1_READINESS_PATH = "/v1/readiness"
    V1_BEDTIME_PATH = "/v1/bedtime"

    PERSONAL_INFO_PATH = "/v2/usercollection/personal_info"
    DAILY_SLEEP_PATH = "/v2/usercollection/daily_sleep"
    SLEEP_PATH = "/v2/usercollection/sleep"
    DAILY_ACTIVITY_PATH = "/v2/usercollection/daily_activity"
    DAILY_READINESS_PATH = "/v2/usercollection/daily_readiness"
    SESSION_PATH = "/v2/usercollection/session"
    TAG_PATH = "/v2/usercollection/tag"
    WORKOUT_PATH = "/v2/usercollection/workout"

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

    # V2 =============

    def personal_info
      request(:personal_info)
    end

    def daily_sleep(start_date = nil, end_date = nil, document_id: nil)
      request(:daily_sleep, start_date, end_date, document_id: document_id)
    end

    def sleep(start_date = nil, end_date = nil)
      request(:sleep, start_date, end_date)
    end

    def daily_activity(start_date = nil, end_date = nil, document_id: nil)
      request(:daily_activity, start_date, end_date, document_id: document_id)
    end

    def daily_readiness(start_date = nil, end_date = nil, document_id: nil)
      request(:daily_readiness, start_date, end_date, document_id: document_id)
    end

    def session(start_date = nil, end_date = nil, document_id: nil)
      request(:session, start_date, end_date, document_id: document_id)
    end

    def tag(start_date = nil, end_date = nil, document_id: nil)
      request(:tag, start_date, end_date, document_id: document_id)
    end

    def workout(start_date = nil, end_date = nil, document_id: nil)
      request(:workout, start_date, end_date, document_id: document_id)
    end

    def request(type, start_date = nil, end_date = nil, document_id: nil)
      return request_document(type, document_id: document_id) if document_id

      params = {}
      params[:start_date] = start_date unless start_date.nil?
      params[:end_date] = end_date unless end_date.nil?

      response = request_api(path_by_type(type), :get, params)
      response_class_by_type(type).new(response)
    end

    def request_document(type, document_id:)
      path = path_by_type(type)
      response = request_api("#{path}/#{document_id}", :get, nil)
      response_class_by_type(type).new(response)
    end

    def path_by_type(type)
      path_name = "#{type.to_s.upcase}_PATH"
      self.class.const_get(path_name)
    end

    def response_class_by_type(type)
      class_name = type.to_s.split('_').map(&:capitalize).join
      OuraRingApi::Response.const_get(class_name)
    rescue NameError => _e
      OuraRingApi::Response::Base
    end

    # V1 =============

    def userinfo
      response = request_api(V1_USERINFO_PATH, :get, nil)
      OuraRingApi::Response::V1::Userinfo.new(response)
    end

    def sleep_summary(start_date = nil,
                      end_date = nil)
      params = {
        start: start_date,
        end: end_date
      }
      response = request_api(V1_SLEEP_PATH, :get, params)
      OuraRingApi::Response::V1::Sleep.new(response)
    end

    def activity_summary(start_date = nil,
                         end_date = nil)
      params = {
        start: start_date,
        end: end_date
      }
      response = request_api(V1_ACTIVITY_PATH, :get, params)
      OuraRingApi::Response::V1::Activity.new(response)
    end

    def readiness_summary(start_date = nil,
                          end_date = nil)
      params = {
        start: start_date,
        end: end_date
      }
      response = request_api(V1_READINESS_PATH, :get, params)
      OuraRingApi::Response::V1::Readiness.new(response)
    end

    def bedtime(start_date = nil,
                end_date = nil)
      params = {
        start: start_date,
        end: end_date
      }
      response = request_api(V1_BEDTIME_PATH, :get, params)
      OuraRingApi::Response::V1::Bedtime.new(response)
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
      client.request(:authorization, :Bearer, access_token)
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
