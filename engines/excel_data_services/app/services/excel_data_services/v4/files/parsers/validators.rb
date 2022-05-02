# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Validators < ExcelDataServices::V4::Files::Parsers::Base
          SPLIT_PATTERN = /^(add_data_validator)|(row_validation)/.freeze

          def row_validations
            @row_validations ||= []
          end

          def data_validations
            @data_validations ||= []
          end

          def add_data_validator(class_name)
            data_validation_class = "ExcelDataServices::V4::Validators::#{class_name}".constantize
            @data_validations << data_validation_class unless data_validations.include?(data_validation_class)
          end

          def row_validation(keys, comparator)
            row_validations << ExcelDataServices::V4::Files::RowValidation.new(keys: keys, comparator: comparator)
          end
        end
      end
    end
  end
end
