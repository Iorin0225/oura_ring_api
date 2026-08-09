# frozen_string_literal: true

require_relative "base"

module OuraRingApi
  module Response
    class PersonalInfo < Base

      KEYS = %w[
        age
        weight
        height
        biological_sex
        email
      ].freeze

      KEYS.each do |key|
        define_method(key) do
          data.first[key]
        end
      end

      def keys
        KEYS
      end
    end
  end
end
