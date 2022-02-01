# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Operations
      class TruckingZones < ExcelDataServices::V3::Operations::Base
        STATE_COLUMNS = %w[hub_id group_id organization_id row sheet_name].freeze
        ZONE_COLUMNS = %w[zone range postal_code distance city province country_code locode].freeze

        def perform
          return state if %w[city locode].include?(identifier) || zone_range_frame.empty?

          super
        end

        private

        def operation_result
          @operation_result ||= frame.left_join(expanded_frame, on: { "range" => "range" })
        end

        def zone_range_frame
          @zone_range_frame ||= Rover::DataFrame.new(frame[!frame["range"].missing][filtered_zone_columns].to_a.uniq)
        end

        def filtered_zone_columns
          @filtered_zone_columns ||= (ZONE_COLUMNS | frame.keys).select { |header| !frame[header].missing && frame[header].any?(&:present?) }
        end

        def identifier
          @identifier ||= frame["identifier"].to_a.first
        end

        def expanded_frame
          @expanded_frame ||= country_codes.each_with_object(Rover::DataFrame.new) do |country_code, zone_range|
            zone_range.concat(
              ExcelDataServices::V3::Operations::ZoneRanges::SingleZoneRangeExpanded.data(
                frame: zone_range_frame,
                country_code: country_code,
                identifier: identifier
              )
            )
          end
        end

        def country_codes
          zone_range_frame["country_code"].uniq.to_a
        end
      end
    end
  end
end
