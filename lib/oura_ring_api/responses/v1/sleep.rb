# frozen_string_literal: true

require_relative "base"

module OuraRingApi
  module Response::V1
    class Sleep < OuraRingApi::Response::V1::Base
      def find_by_date(date)
        date = date.strftime("%Y-%m-%d") if date.respond_to?(:strftime)
        records.select { |record| record.summary_date == date }
      end

      class Record < ::OuraRingApi::Response::V1::Base::Record
        def self.record_key
          "sleep"
        end


        DATE_KEY = "summary_date"
        KEYS = %w[
          summary_date
          period_id
          is_longest
          timezone
          bedtime_end
          bedtime_start
          type
          breath_average
          average_breath_variation
          duration
          total
          awake
          rem
          deep
          light
          midpoint_time
          efficiency
          restless
          onset_latency
          got_up_count
          wake_up_count
          hr_5min
          hypnogram_5min
          rmssd
          rmssd_5min
          score
          score_alignment
          score_deep
          score_disturbances
          score_efficiency
          score_latency
          score_rem
          score_total
          temperature_deviation
          temperature_trend_deviation
          bedtime_start_delta
          bedtime_end_delta
          midpoint_at_delta
          temperature_delta
          hr_lowest
          hr_average
          lowest_heart_rate_time_offset
        ].freeze

        SUMMARY_DATA_KEYS = %w[
          summary_date
          period_id
          is_longest
          timezone
          bedtime_end
          bedtime_start
          type
          breath_average
          average_breath_variation
          duration
          total
          awake
          rem
          deep
          light
          midpoint_time
          efficiency
          restless
          onset_latency
          got_up_count
          wake_up_count
          rmssd
          score
          score_alignment
          score_deep
          score_disturbances
          score_efficiency
          score_latency
          score_rem
          score_total
          temperature_deviation
          temperature_trend_deviation
          bedtime_start_delta
          bedtime_end_delta
          midpoint_at_delta
          temperature_delta
          hr_lowest
          hr_average
          lowest_heart_rate_time_offset
        ].freeze

        DETAIL_DATA_KEYS = %w[
          hr_5min
          hypnogram_5min
          rmssd_5min
        ].freeze

        DURATION_KEYS = %w[
          duration
          total
          awake
          rem
          deep
          light
          midpoint_time
          onset_latency
          bedtime_start_delta
          bedtime_end_delta
          midpoint_at_delta
        ].freeze

        # I couldn't put this on base class ><
        KEYS.each do |key|
          define_method(key) do
            body[key]
          end
        end

        DURATION_KEYS.each do |key|
          define_method("#{key}_format") do
            Time.at(body[key]).utc.strftime("%H:%M:%S")
          end
        end
      end
    end
  end
end
