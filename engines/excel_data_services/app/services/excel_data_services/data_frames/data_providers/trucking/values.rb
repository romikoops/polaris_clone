# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class Values < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "value" => :object
            }
          end

          private

          def data
            extract_from_schema(section: "main_data").map(&:data)
          end

          def label
            "value"
          end
        end
      end
    end
  end
end
