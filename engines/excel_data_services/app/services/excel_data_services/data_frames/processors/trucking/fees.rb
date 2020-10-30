# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Processors
      module Trucking
        class Fees < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::DataFrames::DataProviders::Trucking::Fees,
              ExcelDataServices::DataFrames::Sanitizers::Trucking::Fees,
              ExcelDataServices::DataFrames::Validators::Trucking::Fees,
              ExcelDataServices::DataFrames::Augmenters::Trucking::Fees
            ]
          end
        end
      end
    end
  end
end
