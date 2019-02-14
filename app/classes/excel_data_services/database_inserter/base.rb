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
        @stats = {}
      end

      def perform
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      private

      attr_reader :tenant, :data, :klass_identifier, :options, :stats

      def add_stats(descriptor, data_record)
        @stats[descriptor] ||= {
          number_updated: 0,
          number_created: 0
        }

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
