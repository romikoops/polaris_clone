# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class BracketMinimum < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "bracket_minimum" => ExcelDataServices::Validators::TypeValidity::Types::NumericType
            }
          end
        end
      end
    end
  end
end
