# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Extractions
      module Trucking
        class Zones < ExcelDataServices::DataFrames::Base
          def performing_modules
            [ExcelDataServices::Extractors::Location]
          end
        end
      end
    end
  end
end
