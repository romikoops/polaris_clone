# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Extractions
      module Hubs
        class Hubs < ExcelDataServices::DataFrames::Base
          def performing_modules
            [
              ExcelDataServices::Extractors::MandatoryCharge,
              ExcelDataServices::Extractors::Nexus
            ]
          end
        end
      end
    end
  end
end
