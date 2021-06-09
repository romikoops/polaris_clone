# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Confirmations
      module Hubs
        class Nexuses < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::Validators::Extractions::Country
            ]
          end
        end
      end
    end
  end
end
