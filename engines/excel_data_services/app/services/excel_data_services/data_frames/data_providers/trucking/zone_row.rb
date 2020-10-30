# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class ZoneRow < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "zone" => :object
            }
          end

          private

          attr_reader :file, :schema

          def data
            extract_from_schema(section: "main_data_row_headers").map do |cell|
              cell.data.merge("zone" => cell.value)
            end
          end

          def label
            "zone"
          end
        end
      end
    end
  end
end
