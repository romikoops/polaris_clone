# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Hubs
        class Nexuses < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Hubs::Nexuses,
              ExcelDataServices::DataFrames::Extractions::Hubs::Nexuses,
              ExcelDataServices::DataFrames::Confirmations::Hubs::Nexuses
            ]
          end
        end
      end
    end
  end
end
