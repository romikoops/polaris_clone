# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class FeeMetadata < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "carrier" => ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
              "cargo_class" => ExcelDataServices::Validators::TypeValidity::Types::CargoClassType,
              "direction" => ExcelDataServices::Validators::TypeValidity::Types::DirectionType,
              "truck_type" => ExcelDataServices::Validators::TypeValidity::Types::TruckTypeType,
              "service" => ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType
            }
          end
        end
      end
    end
  end
end
