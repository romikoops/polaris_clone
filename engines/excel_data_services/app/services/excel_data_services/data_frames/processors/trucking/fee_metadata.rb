# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Trucking
        class FeeMetadata < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Trucking::FeeMetadata,
              ExcelDataServices::DataFrames::Augmenters::Trucking::FeeMetadata,
              ExcelDataServices::DataFrames::Extractions::Trucking::FeeMetadata
            ]
          end
        end
      end
    end
  end
end
