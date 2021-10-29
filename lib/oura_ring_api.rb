# frozen_string_literal: true

require "oauth2"
require "faraday"
require "faraday_middleware"

require_relative "oura_ring_api/version"
require_relative "oura_ring_api/client"

module OuraRingApi
  class Error < StandardError; end
end
