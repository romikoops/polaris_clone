# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Trucking
        class Brackets < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Trucking::Brackets,
              ExcelDataServices::DataFrames::Expansions::Trucking::Brackets
            ]
          end
        end
      end
    end
  end
end
