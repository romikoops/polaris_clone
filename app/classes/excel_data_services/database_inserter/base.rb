# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class Base
      InsertionError = Class.new(StandardError)
      InvalidDataExtractionMethodError = Class.new(InsertionError)

      def self.insert(options)
        new(options).perform
      end

      def initialize(tenant:, data:, klass_identifier:, options: {})
        @tenant = tenant
        @data = data
        @klass_identifier = klass_identifier
        @options = options
        @stats = stat_descriptors.each_with_object({}) do |descriptor, hsh|
          hsh[descriptor] = {
            number_updated: 0,
            number_created: 0
          }
        end
      end

      private

      attr_reader :tenant, :data, :klass_identifier, :options, :stats

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

      def append_hub_suffix(name, mot)
        name + ' ' + { 'ocean' => 'Port',
                       'air' => 'Airport',
                       'rail' => 'Railyard',
                       'truck' => 'Depot' }[mot]
      end
    end
  end
end
