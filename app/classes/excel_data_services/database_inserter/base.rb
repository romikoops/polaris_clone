# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class Base
      InsertionError = Class.new(StandardError)
      InvalidDataExtractionMethodError = Class.new(InsertionError)

      def self.insert(options)
        new(options).perform
      end

      def initialize(tenant:, data:, options: {})
        @tenant = tenant
        @data = data
        @options = options
        @stats = stat_descriptors.each_with_object({}) do |descriptor, hsh|
          hsh[descriptor] = {
            number_updated: 0,
            number_created: 0
          }
        end
      end

      private

      attr_reader :tenant, :data, :options, :stats

      def stat_descriptors
        %i(itineraries
           stops
           pricings
           pricing_details)
      end

      def add_stats(descriptor, data_record)
        if data_record.new_record?
          @stats[descriptor][:number_created] += 1
        else
          @stats[descriptor][:number_updated] += 1
        end
      end
    end
  end
end
