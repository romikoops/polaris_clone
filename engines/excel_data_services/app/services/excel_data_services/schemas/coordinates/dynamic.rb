# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Coordinates
      class Dynamic < ExcelDataServices::Schemas::Coordinates::Base
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
          values.length - final_index
        end

        def counterpart_key
          @counterpart_key ||= numerical_value(input: schema.dig(section, counterpart_axis).first)
        end

        def values
          @values ||= if counterpart_axis == "cols"
            sheet.column(counterpart_key)
          else
            sheet.row(counterpart_key)
          end
        end

        def final_index
          @final_index ||= values.reverse.index(&:present?) || values.length
        end
      end
    end
  end
end
