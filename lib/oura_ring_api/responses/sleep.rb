# frozen_string_literal: true

require_relative "base"

module OuraRingApi
  module Response
    class Sleep < Base
      def find_by_date(date)
        date = date.strftime("%Y-%m-%d") if date.respond_to?(:strftime)
        records.select { |row| row.summary_date == date }
      end

      class Row < ::OuraRingApi::Response::Base::Row
        def self.record_key
          "sleep"
        end

        KEYS = %w[
          summary_date
          period_id
          is_longest
          timezone
          bedtime_end
          bedtime_start
          breath_average
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
