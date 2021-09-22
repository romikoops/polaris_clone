# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class Fees < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "service" => :object,
              "carrier" => :object,
              "cargo_class" => :object,
              "zone" => :object,
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
              "percentage" => :object,
              "range_min" => :object,
              "range_max" => :object
            }
          end

          private

          def data
            return {} if cell_data.empty?

            super
          end

          def cell_data
            @cell_data ||= extract_from_schema(section: "data")
          end

          def label
            "fee"
          end
        end
      end
    end
  end
end
