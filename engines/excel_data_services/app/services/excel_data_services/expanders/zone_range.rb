# frozen_string_literal: true

module ExcelDataServices
  module Expanders
    class ZoneRange < ExcelDataServices::Expanders::Base
      def join_arguments
        {"secondary" => "secondary"}
      end

      def identifier
        @identifier ||= frame["identifier"].to_a.first
      end

      def expanded_frame
        return initial_frame if %w[city locode].include?(identifier)

        initial_frame.concat(expanded_range_frame)
      end

      def expanded_range_frame
        Rover::DataFrame.new(expanded_ranges)
      end

      def expanded_ranges
        country_codes.each_with_object(Rover::DataFrame.new) do |country_code, zone_range|
          zone_range.concat(
            ExcelDataServices::Expanders::ZoneRanges::SingleZoneRangeExpanded.data(
              frame: frame,
              country_code: country_code
            )
          )
        end
      end

      def country_codes
        frame["country_code"].uniq.to_a
      end

      def frame_structure
        {
          "primary" => [],
          "secondary" => [],
          "country_code" => []
        }
      end
    end
  end
end
