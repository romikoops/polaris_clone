# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Expansions
      module Trucking
        class Zones < ExcelDataServices::DataFrames::Base
          def performing_modules
            [ExcelDataServices::Expanders::ZoneRange]
          end
        end
      end
    end
  end
end
