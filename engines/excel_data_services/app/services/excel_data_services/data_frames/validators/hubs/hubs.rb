# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Hubs
        class Hubs < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "status" => ExcelDataServices::Validators::TypeValidity::Types::StatusType,
              "type" => ExcelDataServices::Validators::TypeValidity::Types::ModeOfTransportType,
              "name" => ExcelDataServices::Validators::TypeValidity::Types::StringType,
              "locode" => ExcelDataServices::Validators::TypeValidity::Types::LocodeType,
              "terminal" => ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
              "terminal_code" => ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
              "latitude" => ExcelDataServices::Validators::TypeValidity::Types::NumericType,
              "longitude" => ExcelDataServices::Validators::TypeValidity::Types::NumericType,
              "country" => ExcelDataServices::Validators::TypeValidity::Types::StringType,
              "full_address" => ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
              "free_out" => ExcelDataServices::Validators::TypeValidity::Types::BooleanType,
              "import_charges" => ExcelDataServices::Validators::TypeValidity::Types::OptionalBooleanType,
              "export_charges" => ExcelDataServices::Validators::TypeValidity::Types::OptionalBooleanType,
              "pre_carriage" => ExcelDataServices::Validators::TypeValidity::Types::OptionalBooleanType,
              "on_carriage" => ExcelDataServices::Validators::TypeValidity::Types::OptionalBooleanType,
              "alternative_names" => ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
              "organization_id" => ExcelDataServices::Validators::TypeValidity::Types::UuidType
            }
          end
        end
      end
    end
  end
end
