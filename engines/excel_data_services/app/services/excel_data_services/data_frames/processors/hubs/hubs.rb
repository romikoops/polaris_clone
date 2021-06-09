# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Hubs
        class Hubs < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Hubs::Hubs,
              ExcelDataServices::DataFrames::Extractions::Hubs::Hubs,
              ExcelDataServices::DataFrames::Augmenters::Hubs::Hubs,
              ExcelDataServices::DataFrames::Confirmations::Hubs::Hubs
            ]
          end
        end
      end
    end
  end
end
