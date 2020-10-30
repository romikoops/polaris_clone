# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Trucking
        class Zones < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Trucking::Zones,
              ExcelDataServices::DataFrames::Sanitizers::Trucking::Zones,
              ExcelDataServices::DataFrames::Validators::Trucking::Zones,
              ExcelDataServices::DataFrames::Expansions::Trucking::Zones,
              ExcelDataServices::DataFrames::Augmenters::Trucking::Zones,
              ExcelDataServices::DataFrames::Extractions::Trucking::Zones,
              ExcelDataServices::DataFrames::Confirmations::Trucking::Zones
            ]
          end
        end
      end
    end
  end
end
