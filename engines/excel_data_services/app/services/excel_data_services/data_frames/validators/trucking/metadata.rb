# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class Metadata < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "modifier" => ExcelDataServices::Validators::TypeValidity::Types::ModifierType,
              "city" => ExcelDataServices::Validators::TypeValidity::Types::StringType,
              "currency" => ExcelDataServices::Validators::TypeValidity::Types::CurrencyType,
              "load_meterage_ratio" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "load_meterage_limit" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "load_meterage_hard_limit" => ExcelDataServices::Validators::TypeValidity::Types::BooleanType,
              "load_meterage_area" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "load_meterage_stacking" => ExcelDataServices::Validators::TypeValidity::Types::BooleanType,
              "cbm_ratio" => ExcelDataServices::Validators::TypeValidity::Types::NumericType,
              "scale" => ExcelDataServices::Validators::TypeValidity::Types::ModifierType,
              "rate_basis" => ExcelDataServices::Validators::TypeValidity::Types::RateBasisType,
              "base" => ExcelDataServices::Validators::TypeValidity::Types::NumericType,
              "truck_type" => ExcelDataServices::Validators::TypeValidity::Types::TruckTypeType,
              "load_type" => ExcelDataServices::Validators::TypeValidity::Types::LoadTypeType,
              "cargo_class" => ExcelDataServices::Validators::TypeValidity::Types::CargoClassType,
              "direction" => ExcelDataServices::Validators::TypeValidity::Types::DirectionType,
              "carrier" => ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
              "service" => ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
              "mode_of_transport" => ExcelDataServices::Validators::TypeValidity::Types::ModeOfTransportType,
              "effective_date" => ExcelDataServices::Validators::TypeValidity::Types::DateType,
              "expiration_date" => ExcelDataServices::Validators::TypeValidity::Types::DateType
            }
          end
        end
      end
    end
  end
end
