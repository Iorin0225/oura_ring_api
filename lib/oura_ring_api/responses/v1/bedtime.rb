# frozen_string_literal: true

require_relative "base"

module OuraRingApi
  module Response::V1
    class Bedtime < OuraRingApi::Response::V1::Base
      def find_by_date(date)
        date = date.strftime("%Y-%m-%d") if date.respond_to?(:strftime)
        records.select { |record| record.date == date }
      end

      class Record < ::OuraRingApi::Response::V1::Base::Record
        def self.record_key
          "ideal_bedtimes"
        end

        KEYS = %w[
          date
          bedtime_window
          status
        ].freeze

        SUMMARY_DATA_KEYS = KEYS
        DATE_KEY = "date"

        # I couldn't put this on base class ><
        KEYS.each do |key|
          define_method(key) do
            body[key]
          end
        end
      end
    end
  end
end
