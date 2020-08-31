# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Base < ExcelDataServices::Validators::Base
        COLUMN_TO_CLASS_LOOKUP = {}.freeze

        TYPE_VALIDATOR_LOOKUP = {
          fee: Validators::TypeValidity::TypeValidators::FeeValidator,
          load_type: Validators::TypeValidity::TypeValidators::LoadTypeValidator,
          cargo_class: Validators::TypeValidity::TypeValidators::CargoClassValidator,
          locode: Validators::TypeValidity::TypeValidators::OptionalLocodeValidator,
          origin_locode: Validators::TypeValidity::TypeValidators::OptionalLocodeValidator,
          destination_locode: Validators::TypeValidity::TypeValidators::OptionalLocodeValidator,
          date: Validators::TypeValidity::TypeValidators::DateValidator,
          string: Validators::TypeValidity::TypeValidators::StringValidator,
          optional_string: Validators::TypeValidity::TypeValidators::OptionalStringValidator,
          optional_integer: Validators::TypeValidity::TypeValidators::OptionalIntegerValidator,
          optional_numeric: Validators::TypeValidity::TypeValidators::OptionalNumericValidator,
          numeric: Validators::TypeValidity::TypeValidators::NumericValidator,
          optional_boolean: Validators::TypeValidity::TypeValidators::OptionalBooleanValidator,
          integer: Validators::TypeValidity::TypeValidators::IntegerValidator,
          internal: Validators::TypeValidity::TypeValidators::OptionalInternalValidator
        }.freeze

        EXCEPTION_LOOKUP = {
          fee: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidFee,
          load_type: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidLoadType,
          cargo_class: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidCargoClass,
          locode: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidOptionalLocode,
          date: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidDate,
          string: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidString,
          optional_string: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidOptionalString,
          optional_integer: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidOptionalInteger,
          optional_numeric: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidOptionalNumeric,
          numeric: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidNumeric,
          optional_boolean: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidOptionalBoolean,
          integer: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidInteger,
          internal: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidOptionalInternal
        }.freeze

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
              type = "#{self.class}::COLUMN_TO_CLASS_LOOKUP".constantize[key]
              next if type.nil?

              next if TYPE_VALIDATOR_LOOKUP[type].new(val).valid?

              add_to_errors(
                type: :type_error,
                row_nr: row[:row_nr],
                sheet_name: sheet[:sheet_name],
                reason: "The value: #{val} of the key: #{key} is not a valid #{type}.",
                exception_class: EXCEPTION_LOOKUP[type]
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
