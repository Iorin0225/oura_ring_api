# frozen_string_literal: true

require_relative "../base"

module OuraRingApi
  module Response::V1
    class Readiness < OuraRingApi::Response::Base
      def find_by_date(date)
        date = date.strftime("%Y-%m-%d") if date.respond_to?(:strftime)
        records.select { |record| record.summary_date == date }
      end

      class Record < ::OuraRingApi::Response::Base::Record
        def self.record_key
          "readiness"
        end

        DATE_KEY = "summary_date"
        KEYS = %w[
          summary_date
          period_id
          score
          score_activity_balance
          score_hrv_balance
          score_previous_day
          score_previous_night
          score_recovery_index
          score_resting_hr
          score_sleep_balance
          score_temperature
          rest_mode_state
        ].freeze

        SUMMARY_DATA_KEYS = KEYS

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
