# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class Zones < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "zone" => ExcelDataServices::Validators::TypeValidity::Types::ZoneType,
              "primary_zipcode" => ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
              "primary_postal_code" => ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
              "primary_city" => ExcelDataServices::Validators::TypeValidity::Types::StringType,
              "primary_locode" => ExcelDataServices::Validators::TypeValidity::Types::LocodeType,
              "primary_distance" => ExcelDataServices::Validators::TypeValidity::Types::OptionalIntegerLikeType,
              "secondary_zipcode" => ExcelDataServices::Validators::TypeValidity::Types::ZoneRangeType,
              "secondary_postal_code" => ExcelDataServices::Validators::TypeValidity::Types::ZoneRangeType,
              "secondary_city" => ExcelDataServices::Validators::TypeValidity::Types::StringType,
              "secondary_distance" => ExcelDataServices::Validators::TypeValidity::Types::ZoneRangeType,
              "country_code" => ExcelDataServices::Validators::TypeValidity::Types::CountryCodeType
            }
          end
        end
      end
    end
  end
end
