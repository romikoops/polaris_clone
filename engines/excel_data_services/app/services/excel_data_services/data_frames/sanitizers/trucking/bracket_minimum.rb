# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class BracketMinimum < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "bracket_minimum" => "decimal"
            }
          end

          def default_values
            {
              "bracket_minimum" => 0.0
            }
          end
        end
      end
    end
  end
end
