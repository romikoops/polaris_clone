# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class Zones < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "zone" => "string",
              "primary_postal_code" => "zone",
              "primary_locode" => "string",
              "primary_city" => "string",
              "primary_zipcode" => "string",
              "primary_distance" => "string",
              "secondary_postal_code" => "zone",
              "secondary_locode" => "string",
              "secondary_city" => "string",
              "secondary_zipcode" => "string",
              "secondary_distance" => "string",
              "country_code" => "upcase"
            }
          end
        end
      end
    end
  end
end
