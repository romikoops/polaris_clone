# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Trucking
        class Values < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Trucking::Values
            ]
          end
        end
      end
    end
  end
end
