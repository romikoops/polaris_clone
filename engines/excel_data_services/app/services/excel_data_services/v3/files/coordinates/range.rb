# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Coordinates
        # Range Coordinates provide the upper and lower bounds for a range of rows/columns
        class Range < ExcelDataServices::V3::Files::Coordinates::Base
          def limits
            coordinates.split(":")
          end
        end
      end
    end
  end
end
