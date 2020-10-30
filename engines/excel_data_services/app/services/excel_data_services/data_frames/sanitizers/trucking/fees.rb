# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class Fees < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
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
              "percentage" => "decimal"
            }
          end
        end
      end
    end
  end
end
