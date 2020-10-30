# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class Modifiers < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "modifier" => ExcelDataServices::Validators::TypeValidity::Types::ModifierType
            }
          end
        end
      end
    end
  end
end
