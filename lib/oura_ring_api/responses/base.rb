# frozen_string_literal: true

module OuraRingApi
  module Response
    class Base
      attr_accessor :response, :records

      def initialize(response)
        self.response = response
        parse_to_records! if success? && multiple?
      end

      def multiple?
        true
      end

      def success?
        response.success?
      end

      def status
        response.status
      end

      def body
        response.body
      end

      def record_class
        Kernel.const_get "#{self.class.name}::Record"
      end

      def parse_to_records!
        return unless multiple?

        self.records = record_class.parse!(response)
      end

      def find_by_date(_date)
        raise "#{self.class.name} isn't multiple response." unless multiple?

        raise "Please implement this in #{name}."
      end

      def score_summary
        records.map do |record|
          { record.summary_date.to_s => record.score }
        end
      end

      def summary_by_date(keys = record_class::SUMMARY_DATA_KEYS)
        records.map do |record|
          data = keys.map { |key| { key => record.send(key) } }
          { record.summary_date.to_s => data }
        end
      end

      class Record
        attr_accessor :body

        KEYS = %w[].freeze # put keys on child class
        SUMMARY_DATA_KEYS = %w[].freeze # put keys about summary data
        DETAIL_DATA_KEYS = %w[].freeze # put keys about detailed data

        def initialize(row_body)
          self.body = row_body
        end

        def self.parse!(response)
          response.body[record_key].map do |record|
            new(record)
          end
        end

        def self.record_key
          raise "Please implement this in #{name}."
        end

        def keys
          self.class::KEYS
        end
      end
    end
  end
end