# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class CountryCodes < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "country_code" => "upcase"
            }
          end
        end
      end
    end
  end
end
