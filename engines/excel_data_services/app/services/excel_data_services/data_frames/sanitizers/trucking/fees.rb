# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class Fees < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "zone" => "string",
              "service" => "string",
              "carrier" => "string",
              "cargo_class" => "downcase",
              "fee" => "string",
              "mot" => "downcase",
              "fee_code" => "upcase",
              "truck_type" => "downcase",
              "direction" => "downcase",
              "currency" => "upcase",
              "rate_basis" => "upcase",
              "ton" => "decimal",
              "cbm" => "decimal",
              "kg" => "decimal",
              "item" => "decimal",
              "shipment" => "decimal",
              "bill" => "decimal",
              "container" => "decimal",
              "minimum" => "decimal",
              "wm" => "decimal",
              "percentage" => "decimal",
              "range_min" => "decimal",
              "range_max" => "decimal"
            }
          end

          def default_values
            {
              "percentage" => nil
            }
          end
        end
      end
    end
  end
end
