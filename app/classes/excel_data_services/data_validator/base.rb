# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    class Base
      def self.get(flavor, klass_identifier)
        "#{parent}::#{flavor.titleize.delete(' ')}::#{klass_identifier}".constantize
      end

      def self.validate(options)
        new(options).perform
      end

      def initialize(tenant:, data:, klass_identifier:)
        @tenant = tenant
        @data = data
        @klass_identifier = klass_identifier
        @errors = []
      end

      def perform
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      private

      attr_reader :tenant, :data, :errors, :klass_identifier

      def add_to_errors(row_nr:, reason:)
        @errors << { row_nr: row_nr, reason: reason }
      end
    end
  end
end
