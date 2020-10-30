# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Truckings
        class TypeAvailabilities < ExcelDataServices::DataFrames::Restructurers::Base
          attr_reader :result

          def perform
            restructured_data.to_a.uniq
          end

          def restructured_data
            combined_data[insert_keys]
          end

          def combined_data
            frame
          end

          def insert_keys
            ["country_id", "truck_type", "carriage", "load_type", "query_method"]
          end
        end
      end
    end
  end
end
