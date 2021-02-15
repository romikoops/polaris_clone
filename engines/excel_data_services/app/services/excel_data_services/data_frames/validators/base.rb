# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      class Base
        delegate :sheet_name, :row, :col, :label, to: :cell, allow_nil: true

        def self.validate(cell:, value:, header:)
          new(cell: cell, value: value, header: header).perform
        end

        def initialize(cell:, value:, header:)
          @cell = cell
          @value = value
          @header = header
        end

        def perform
          return if validator.nil? || validator.new(value).valid?

          error
        end

        private

        attr_reader :cell, :value, :header

        def validator
          schema_validator_lookup[header]
        end

        def error
          ExcelDataServices::DataFrames::Validators::Error.new(
            type: :type_error,
            row_nr: row,
            col_nr: col,
            sheet_name: sheet_name,
            reason: "The value: #{value} of the key: #{header} is not a valid #{type}.",
            exception_class: exception_from_type(type: type)
          )
        end

        def type
          validator.name.demodulize
        end

        def exception_from_type(type:)
          ExcelDataServices::Validators::ValidationErrors::TypeValidity.const_get(type)
        end
      end
    end
  end
end
