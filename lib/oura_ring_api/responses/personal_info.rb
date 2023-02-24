# frozen_string_literal: true

require_relative "v1/base"

module OuraRingApi
  module Response
    class PersonalInfo < ::OuraRingApi::Response::V1::Base
      def multiple?
        false
      end

      KEYS = %w[
        age
        weight
        height
        biological_sex
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
