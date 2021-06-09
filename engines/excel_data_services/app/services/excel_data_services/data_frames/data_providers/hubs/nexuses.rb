# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Hubs
        class Nexuses < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "type" => :object,
              "name" => :object,
              "locode" => :object,
              "terminal" => :object,
              "terminal_code" => :object,
              "latitude" => :object,
              "longitude" => :object,
              "country" => :object
            }
          end

          private

          def cell_data
            @cell_data ||= extract_from_schema(section: "data")
          end

          def label
            "nexuses"
          end
        end
      end
    end
  end
end
