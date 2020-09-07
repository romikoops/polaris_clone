# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Base < ExcelDataServices::Validators::Base
        COLUMN_TO_CLASS_LOOKUP = {}.freeze

        def initialize(sheet:)
          @sheet = sheet
          @errors_and_warnings = []
        end

        def self.get(restructurer_name)
          "ExcelDataServices::Validators::TypeValidity::#{restructurer_name.titleize.delete(' ')}".constantize
        end

        def type_errors
          sheet[:rows_data].each do |row|
            row.each do |key, val|
              type_validator = self.class::COLUMN_TO_CLASS_LOOKUP.fetch(
                key,
                ExcelDataServices::Validators::TypeValidity::Types::AnyType
              )

              next if type_validator.new(val).valid?

              type = type_validator.name.demodulize
              add_to_errors(
                type: :error,
                row_nr: row[:row_nr],
                sheet_name: sheet[:sheet_name],
                reason: "The value: #{val} of the key: #{key} is not a valid #{type.underscore.tr("_", " ")}.",
                exception_class: ExcelDataServices::Validators::ValidationErrors::TypeValidity.const_get(type)
              )
            end
          end

          errors_and_warnings
        end

        private

        attr_reader :sheet
      end
    end
  end
end
