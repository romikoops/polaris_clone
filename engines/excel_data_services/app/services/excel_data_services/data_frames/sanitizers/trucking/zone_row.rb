# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class ZoneRow < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "zone" => "string"
            }
          end
        end
      end
    end
  end
end
