# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Confirmations
      module Hubs
        class Hubs < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::Validators::Extractions::Address,
              ExcelDataServices::Validators::Extractions::MandatoryCharge,
              ExcelDataServices::Validators::Extractions::Nexus
            ]
          end
        end
      end
    end
  end
end
