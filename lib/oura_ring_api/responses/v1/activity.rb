# frozen_string_literal: true

require_relative "base"

module OuraRingApi
  module Response::V1
    class Activity < OuraRingApi::Response::V1::Base
      def find_by_date(date)
        date = date.strftime("%Y-%m-%d") if date.respond_to?(:strftime)
        records.select { |record| record.summary_date == date }
      end

      class Record < ::OuraRingApi::Response::V1::Base::Record
        def self.record_key
          "activity"
        end

        DATE_KEY = "summary_date"
        KEYS = %w[
          summary_date
          timezone
          day_start
          day_end
          cal_active
          cal_total
          class_5min
          steps
          daily_movement
          non_wear
          rest
          inactive
          low
          medium
          high
          inactivity_alerts
          average_met
          met_1min
          met_min_inactive
          met_min_low
          met_min_medium
          met_min_high
          target_calories
          target_km
          target_miles
          to_target_km
          to_target_miles
          score
          score_meet_daily_targets
          score_move_every_hour
          score_recovery_time
          score_stay_active
          score_training_frequency
          score_training_volume
          rest_mode_state
          total
        ].freeze

        SUMMARY_DATA_KEYS = %w[
          summary_date
          timezone
          day_start
          day_end
          cal_active
          cal_total
          steps
          daily_movement
          non_wear
          rest
          inactive
          low
          medium
          high
          inactivity_alerts
          average_met
          met_min_inactive
          met_min_low
          met_min_medium
          met_min_high
          target_calories
          target_km
          target_miles
          to_target_km
          to_target_miles
          score
          score_meet_daily_targets
          score_move_every_hour
          score_recovery_time
          score_stay_active
          score_training_frequency
          score_training_volume
          rest_mode_state
          total
        ].freeze

        DETAIL_DATA_KEYS = %w[
          class_5min
          met_1min
        ].freeze

        DURATION_KEYS = %w[
          non_wear
          rest
          inactive
          low
          medium
          high
          rest_mode_state
          total
        ].freeze

        # I couldn't put this on base class ><
        KEYS.each do |key|
          define_method(key) do
            body[key]
          end
        end

        DURATION_KEYS.each do |key|
          define_method("#{key}_format") do
            Time.at(body[key]*60).utc.strftime("%H:%M:%S")
          end
        end

        def rest_mode_state_format
          case rest_mode_state
          when 0
            "Off"
          when 1
            "Entering Rest Mode"
          when 2
            "Rest Mode"
          when 3
            "Entering recovery"
          when 4
            "Recovering"
          else
            "Invalid Data"
          end
        end
      end
    end
  end
end
