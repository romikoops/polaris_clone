# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class Brackets < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "bracket" => ExcelDataServices::Validators::TypeValidity::Types::BracketType
            }
          end
        end
      end
    end
  end
end
