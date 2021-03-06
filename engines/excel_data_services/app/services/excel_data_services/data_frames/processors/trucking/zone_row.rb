# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Trucking
        class ZoneRow < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Trucking::ZoneRow,
              ExcelDataServices::DataFrames::Augmenters::Trucking::ZoneRow
            ]
          end
        end
      end
    end
  end
end
