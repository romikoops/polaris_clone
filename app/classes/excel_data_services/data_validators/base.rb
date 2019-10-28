# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    class Base < ExcelDataServices::Base
      def self.get(flavor, klass_identifier)
        "#{parent}::#{flavor.titleize.delete(' ')}::#{klass_identifier}".constantize
      end

      def initialize(tenant:, data:)
        @tenant = tenant
        @data = data
        @klass_identifier = self.class.name.split('::').last
        @errors = []
      end

      def perform
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      def errors
        @errors.uniq
      end

      def valid?
        errors.select { |error| error[:type] == :error }.empty?
      end

      def errors_obj
        { has_errors: !valid?, errors: errors.select { |error| error[:type] == :error } }
      end

      private

      attr_reader :tenant, :data, :klass_identifier

      def add_to_errors(type:, row_nr:, reason:, exception_class:)
        @errors << { type: type, row_nr: row_nr, reason: reason, exception_class: exception_class }
      end
    end
  end
end
