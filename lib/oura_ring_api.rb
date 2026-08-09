# frozen_string_literal: true

require "oauth2"
require "faraday"
require "faraday_middleware"

require_relative "oura_ring_api/version"
require_relative "oura_ring_api/client"

module OuraRingApi
  class Error < StandardError; end

  class HttpError < Error
    attr_reader :status, :body, :headers

    def initialize(status:, body:, headers:)
      @status = status
      @body = body
      @headers = headers
      super("Oura API request failed with HTTP #{status}")
    end
  end
end
