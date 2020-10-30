# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Coordinates
      class Relative < ExcelDataServices::Schemas::Coordinates::Base
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
          relative_result.last
        end

        def relative_result
          @relative_result ||= ExcelDataServices::Schemas::Coordinates::Base.extract(
            source: source, section: other_section, axis: other_axis
          )
        end

        def other_section
          @other_section ||= relative_section.split(".").first
        end

        def other_axis
          @other_axis ||= relative_axis.gsub("last_", "") + "s"
        end

        def relative_axis
          @relative_axis ||= relative_section.split(".").last
        end

        def relative_section
          @relative_section ||= characters.find { |char| char.include?(".") }
        end
      end
    end
  end
end
