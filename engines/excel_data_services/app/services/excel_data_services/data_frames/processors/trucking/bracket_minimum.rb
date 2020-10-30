# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Trucking
        class BracketMinimum < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Trucking::BracketMinimum,
              ExcelDataServices::DataFrames::Sanitizers::Trucking::BracketMinimum,
              ExcelDataServices::DataFrames::Validators::Trucking::BracketMinimum
            ]
          end
        end
      end
    end
  end
end
