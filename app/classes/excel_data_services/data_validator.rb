# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    ValidationError = Class.new(StandardError)

    def self.get(flavor, klass_identifier)
      "ExcelDataServices::DataValidator::#{flavor.titleize.delete(' ')}::#{klass_identifier}".constantize
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def validate(options)
        new(options).perform
      end
    end

    def initialize(data:, tenant:, klass_identifier:)
      @data = data
      @tenant = tenant
      @klass_identifier = klass_identifier
      @errors = []
    end

    def perform
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    private

    attr_reader :data, :tenant, :errors, :klass_identifier

    def add_to_errors(row_nr:, reason:)
      @errors << { row_nr: row_nr,
                   reason: reason }
    end
  end
end
