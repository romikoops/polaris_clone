# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Coordinates
        # Dynamic Coordinates run until the content in the row/column is finished.
        class Dynamic < ExcelDataServices::V3::Files::Coordinates::Base
          def limits
            [lower, upper]
          end

          private

          def characters
            @characters ||= coordinates.split(":")
          end

          def lower
            characters.first
          end

          def upper
            [NumericalInput.new(input: lower).value + 1, values.length - 1].max
          end

          def counterpart_key
            @counterpart_key ||= NumericalInput.new(input: counterpart.first).value
          end

          def values
            @values ||= if counterpart_axis == "cols"
              sheet.column(counterpart_key)
            else
              sheet.row(counterpart_key)
            end
          end
        end
      end
    end
  end
end
