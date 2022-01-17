# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Coordinates
        # Relative Coordinates reference another part of the Schema and call that sections Coordinates to find the end of that content to apply to this sections upper and lower limit.
        class Relative < ExcelDataServices::V3::Files::Coordinates::Base
          def limits
            [lower, upper]
          end

          private

          def coordinate_parts
            @coordinate_parts ||= coordinates.split(":")
          end

          def lower
            coordinate_parts.first
          end

          def upper
            upper_counterpart = relative_result.last
            if axis == "cols"
              sheet.row(upper_counterpart).count
            else
              sheet.column(upper_counterpart).count
            end
          end

          def relative_result
            @relative_result ||= ExcelDataServices::V3::Files::Coordinates::Base.extract(
              sheet: sheet, coordinates: counterpart, counterpart: coordinates, axis: other_axis
            )
          end

          def other_axis
            @other_axis ||= "#{relative_section.split('.').last.gsub('last_', '')}s"
          end

          def relative_section
            @relative_section ||= coordinate_parts.find { |char| char.include?(".") }
          end
        end
      end
    end
  end
end
