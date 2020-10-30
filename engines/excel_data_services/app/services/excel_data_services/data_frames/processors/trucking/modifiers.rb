# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Trucking
        class Modifiers < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Trucking::Modifiers,
              ExcelDataServices::DataFrames::Sanitizers::Trucking::Modifiers,
              ExcelDataServices::DataFrames::Validators::Trucking::Modifiers
            ]
          end
        end
      end
    end
  end
end
