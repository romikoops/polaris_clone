# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class Brackets < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "bracket" => :object
            }
          end

          private

          attr_reader :file, :schema

          def data
            extract_from_schema(section: "main_data_col_headers").map(&:data)
          end

          def label
            "bracket"
          end
        end
      end
    end
  end
end
