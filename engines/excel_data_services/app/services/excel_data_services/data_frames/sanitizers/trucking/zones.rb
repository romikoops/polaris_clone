# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class Zones < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "zone" => "string",
              "primary" => "string",
              "secondary" => "string",
              "country_code" => "upcase"
            }
          end
        end
      end
    end
  end
end
