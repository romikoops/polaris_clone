# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class Values < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "value" => ExcelDataServices::Validators::TypeValidity::Types::NumericType
            }
          end
        end
      end
    end
  end
end
