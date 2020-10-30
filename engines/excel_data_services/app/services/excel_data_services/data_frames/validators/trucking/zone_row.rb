# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      module Trucking
        class ZoneRow < ExcelDataServices::DataFrames::Validators::Base
          def schema_validator_lookup
            {
              "zone" => ExcelDataServices::Validators::TypeValidity::Types::ZoneType
            }
          end
        end
      end
    end
  end
end
