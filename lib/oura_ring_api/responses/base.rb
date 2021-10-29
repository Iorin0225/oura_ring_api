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

      def row_class
        Kernel.const_get "#{self.class.name}::Row"
      end

      def parse_to_records!
        return unless multiple?

        self.records = row_class.parse!(response)
      end

      def find_by_date(_date)
        raise "#{self.class.name} isn't multiple response." unless multiple?

        raise "Please implement this in #{name}."
      end

      class Row
        attr_accessor :record

        KEYS = %w[].freeze # put keys on child class

        def initialize(record)
          self.record = record
        end

        def self.parse!(response)
          response.body[record_key].map do |row|
            new(row)
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
