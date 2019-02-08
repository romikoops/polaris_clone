# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurer
    class Base
      WillBeRefactoredRestructuringError = Class.new(StandardError)

      def self.restructure_data(options)
        new(options).perform
      end

      def initialize(data:, tenant:)
        @data = data
        @tenant = tenant
      end

      def perform
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      def append_hub_suffix(name, mot)
        name + ' ' + { 'ocean' => 'Port',
                       'air' => 'Airport',
                       'rail' => 'Railyard',
                       'truck' => 'Depot' }[mot]
      end

      private

      attr_reader :data, :tenant
    end
  end
end
