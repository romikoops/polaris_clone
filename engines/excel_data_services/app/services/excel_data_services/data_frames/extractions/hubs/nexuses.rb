# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Extractions
      module Hubs
        class Nexuses < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::Extractors::Country
            ]
          end
        end
      end
    end
  end
end
