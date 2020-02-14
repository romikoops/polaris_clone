# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Base < ExcelDataServices::Validators::Base
        TYPE_VALIDATOR_LOOKUP = {
          fee: Validators::TypeValidity::TypeValidators::FeeValidator,
          locode: Validators::TypeValidity::TypeValidators::LocodeValidator,
          date: Validators::TypeValidity::TypeValidators::DateValidator,
          required_string: Validators::TypeValidity::TypeValidators::StringValidator,
          optional_string: Validators::TypeValidity::TypeValidators::OptionalStringValidator,
          internal: Validators::TypeValidity::TypeValidators::InternalValidator
        }.freeze

        EXCEPTION_LOOKUP = {
          fee: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidFee,
          locode: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidLocode,
          date: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidDate,
          required_string: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidString,
          optional_string: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidOptionalString,
          internal: ExcelDataServices::Validators::ValidationErrors::TypeValidity::InvalidInternal
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
