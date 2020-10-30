# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class ZoneMinimum < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "zone_minimum" => "decimal"
            }
          end

          def default_values
            {
              "zone_minimum" => 0.0
            }
          end
        end
      end
    end
  end
end
