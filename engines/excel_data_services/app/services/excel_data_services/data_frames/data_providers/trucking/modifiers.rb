# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      module Trucking
        class Modifiers < ExcelDataServices::DataFrames::DataProviders::Base
          def self.column_types
            {
              "modifier" => :object
            }
          end

          private

          attr_reader :file, :schema

          def data
            extract_from_schema(section: "column_types").map(&:data)
          end

          def label
            "modifier"
          end
        end
      end
    end
  end
end
