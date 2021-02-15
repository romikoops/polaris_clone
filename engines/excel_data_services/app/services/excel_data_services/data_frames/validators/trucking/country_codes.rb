# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class CountryCodes < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "country_code" => ExcelDataServices::Validators::TypeValidity::Types::CountryCodeType
            }
          end
        end
      end
    end
  end
end
