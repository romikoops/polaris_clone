# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Trucking
        class ZoneMinimum < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Trucking::ZoneMinimum,
              ExcelDataServices::DataFrames::Sanitizers::Trucking::ZoneMinimum,
              ExcelDataServices::DataFrames::Validators::Trucking::ZoneMinimum
            ]
          end
        end
      end
    end
  end
end
