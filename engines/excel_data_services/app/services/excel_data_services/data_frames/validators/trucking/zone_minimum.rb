# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class ZoneMinimum < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "zone_minimum" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType
            }
          end
        end
      end
    end
  end
end
