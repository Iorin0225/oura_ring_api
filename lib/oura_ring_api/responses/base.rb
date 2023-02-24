# frozen_string_literal: true

module OuraRingApi
  module Response
    class Base
      attr_accessor :response
      attr_accessor :records

      def initialize(response)
        self.response = response
        parse_to_records
      end

      def success?
        response.success?
      end

      def data
        if response.body.key?("data")
          response.body["data"]
        else
          [response.body]
        end
      end

      def data_with_day
        return @data_with_day if @data_with_day

        @data_with_day = {}
        data.each do |data_row|
          @data_with_day[data_row["day"]] = data_row
        end

        @data_with_day
      end

      def data_by_day(day)
        data_with_day[day]
      end

      def days
        data_with_day.keys
      end

      alias keys days

      def record_class
        Kernel.const_get "#{self.class.name}::Record"
      end

      def parse_to_records
        self.records = []

        data.each do |data_row|
          records << record_class.new(data_row)
        end
      end

      def record_with_day
        return @record_with_day if @record_with_day

        @record_with_day = {}
        records.each do |record|
          @record_with_day[record.day] = record
        end

        @record_with_day
      end

      def record_by_day(day)
        record_with_day[day]
      end

      class Record
        attr_accessor :original_record

        def initialize(original_record)
          self.original_record = original_record
          hash_key_to_method
        end

        def hash_key_to_method
          original_record.keys.each do |key|
            self.class.send(:define_method, key) do
              original_record[key]
            end
          end
        end

        def keys
          original_record.keys
        end
      end
    end
  end
end
