# frozen_string_literal: true

require_relative "base"

module OuraRingApi
  module Response
    class Readiness < Base
      def find_by_date(date)
        date = date.strftime("%Y-%m-%d") if date.respond_to?(:strftime)
        records.select { |row| row.summary_date == date }
      end

      class Row < ::OuraRingApi::Response::Base::Row
        def self.record_key
          "readiness"
        end

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

        # I couldn't put this on base class ><
        KEYS.each do |key|
          define_method(key) do
            record[key]
          end
        end
      end
    end
  end
end
