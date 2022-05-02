# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Coordinates
        # Range Coordinates provide the upper and lower bounds for a range of rows/columns
        class Range < ExcelDataServices::V4::Files::Coordinates::Base
          def limits
            coordinates.split(":")
          end
        end
      end
    end
  end
end
