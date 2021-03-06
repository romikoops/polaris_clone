# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Coordinates
        # List coordinates are a comma separated list of column/row values.

        class List < ExcelDataServices::V4::Files::Coordinates::Base
          def perform
            coordinates.split(/[|,]/).map { |value| NumericalInput.new(input: value).value }
          end
        end
      end
    end
  end
end
