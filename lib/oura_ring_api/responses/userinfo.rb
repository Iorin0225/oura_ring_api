# frozen_string_literal: true

require_relative "base"

module OuraRingApi
  module Response
    class Userinfo < Base
      def multiple?
        false
      end

      KEYS = %w[
        age
        weight
        height
        gender
        email
      ].freeze

      KEYS.each do |key|
        define_method(key) do
          body[key]
        end
      end

      def keys
        KEYS
      end
    end
  end
end
