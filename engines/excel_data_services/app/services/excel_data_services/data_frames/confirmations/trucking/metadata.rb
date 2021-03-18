# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Confirmations
      module Trucking
        class Metadata < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::Validators::Extractions::TenantVehicle,
              ExcelDataServices::Validators::Extractions::Hub
            ]
          end
        end
      end
    end
  end
end
