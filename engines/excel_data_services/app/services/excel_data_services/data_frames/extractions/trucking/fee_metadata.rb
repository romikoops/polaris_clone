# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Extractions
      module Trucking
        class FeeMetadata < ExcelDataServices::DataFrames::Base
          def performing_modules
            [ExcelDataServices::Extractors::TenantVehicle]
          end
        end
      end
    end
  end
end
