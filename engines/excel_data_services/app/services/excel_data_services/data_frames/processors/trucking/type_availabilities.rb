# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Trucking
        class TypeAvailabilities < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Trucking::Metadata,
              ExcelDataServices::DataFrames::Augmenters::Trucking::Metadata,
              ExcelDataServices::DataFrames::Extractions::Trucking::Metadata,
              ExcelDataServices::DataFrames::Confirmations::Trucking::Metadata
            ]
          end
        end
      end
    end
  end
end
