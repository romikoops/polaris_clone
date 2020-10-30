# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class Fees < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "fee" => ExcelDataServices::Validators::TypeValidity::Types::StringType,
              "mot" => ExcelDataServices::Validators::TypeValidity::Types::ModeOfTransportType,
              "fee_code" => ExcelDataServices::Validators::TypeValidity::Types::StringType,
              "truck_type" => ExcelDataServices::Validators::TypeValidity::Types::TruckTypeType,
              "direction" => ExcelDataServices::Validators::TypeValidity::Types::DirectionType,
              "currency" => ExcelDataServices::Validators::TypeValidity::Types::CurrencyType,
              "rate_basis" => ExcelDataServices::Validators::TypeValidity::Types::RateBasisType,
              "ton" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "cbm" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "kg" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "item" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "shipment" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "bill" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "container" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "minimum" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "wm" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
              "percentage" => ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType
            }
          end
        end
      end
    end
  end
end
