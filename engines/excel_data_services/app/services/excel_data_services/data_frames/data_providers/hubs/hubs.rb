# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Hubs
        class Hubs < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "status" => :object,
              "type" => :object,
              "name" => :object,
              "locode" => :object,
              "terminal" => :object,
              "terminal_code" => :object,
              "latitude" => :object,
              "longitude" => :object,
              "country" => :object,
              "full_address" => :object,
              "free_out" => :bool,
              "import_charges" => :bool,
              "export_charges" => :bool,
              "pre_carriage" => :bool,
              "on_carriage" => :bool,
              "alternative_names" => :object
            }
          end

          private

          def cell_data
            @cell_data ||= extract_from_schema(section: "data")
          end

          def label
            "hub"
          end
        end
      end
    end
  end
end
