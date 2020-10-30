# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class Fees < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "fee" => :object,
              "mot" => :object,
              "fee_code" => :object,
              "truck_type" => :object,
              "direction" => :object,
              "currency" => :object,
              "rate_basis" => :object,
              "ton" => :object,
              "cbm" => :object,
              "kg" => :object,
              "item" => :object,
              "shipment" => :object,
              "bill" => :object,
              "container" => :object,
              "minimum" => :object,
              "wm" => :object,
              "percentage" => :object
            }
          end

          private

          def cell_data
            extract_from_schema(section: "data")
          end

          def label
            "fee"
          end
        end
      end
    end
  end
end
