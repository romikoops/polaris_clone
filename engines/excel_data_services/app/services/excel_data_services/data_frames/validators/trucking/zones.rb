# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class Zones < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "zone" => ExcelDataServices::Validators::TypeValidity::Types::ZoneType,
              "primary" => primary_validator,
              "secondary" => secondary_validator,
              "country_code" => ExcelDataServices::Validators::TypeValidity::Types::CountryCodeType
            }
          end

          def primary_validator
            case identifier
            when "zipcode", "postal_code"
              ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType
            when "city"
              ExcelDataServices::Validators::TypeValidity::Types::StringType
            when "distance"
              ExcelDataServices::Validators::TypeValidity::Types::OptionalIntegerLikeType
            else
              ExcelDataServices::Validators::TypeValidity::Types::LocodeType
            end
          end

          def secondary_validator
            case identifier
            when "zipcode", "postal_code", "distance"
              ExcelDataServices::Validators::TypeValidity::Types::ZoneRangeType
            when "city"
              ExcelDataServices::Validators::TypeValidity::Types::StringType
            else
              ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType
            end
          end

          def identifier
            @identifier ||= frame["identifier"].to_a.first
          end
        end
      end
    end
  end
end
