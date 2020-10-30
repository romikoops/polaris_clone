# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Confirmations
      module Trucking
        class Zones < ExcelDataServices::DataFrames::Base
          def performing_modules
            [ExcelDataServices::Validators::Extractions::Location]
          end
        end
      end
    end
  end
end
