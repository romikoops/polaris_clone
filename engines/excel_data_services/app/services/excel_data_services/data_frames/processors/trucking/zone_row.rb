# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Trucking
        class ZoneRow < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Trucking::ZoneRow,
              ExcelDataServices::DataFrames::Sanitizers::Trucking::ZoneRow,
              ExcelDataServices::DataFrames::Validators::Trucking::ZoneRow
            ]
          end
        end
      end
    end
  end
end
