# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class RouteHubs < ExcelDataServices::V2::Extractors::Base
        # All Sections that involve Itineraries will need origin_hub_id and destination_hub_id. This class extracts those values based off data from the sheet and appends error messages if it is not found
        ROUTING_ROW_KEYS = %w[row sheet_name origin_locode origin origin_terminal country_origin destination_locode destination destination_terminal country_destination mode_of_transport].freeze

        def frame_data
          base_frame # Ensure we have columns to join on
            .left_join(final_origin_frame, on: join_arguments) # Join in all origin results that got an id
            .left_join(final_destination_frame, on: join_arguments) # Join in all destination results that got an id
        end

        def final_origin_frame
          @final_origin_frame ||= final_frame(
            target_frame: origin_hub_frame,
            joins: origin_joins,
            required_key: "origin_hub_id",
            keys: %w[origin_hub_id origin_name]
          )
        end

        def final_destination_frame
          @final_destination_frame ||= final_frame(
            target_frame: destination_hub_frame,
            joins: destination_joins,
            required_key: "destination_hub_id",
            keys: %w[destination_hub_id destination_name]
          )
        end

        def final_frame(target_frame:, joins:, required_key:, keys:)
          full_frame = joins.each_with_object(blank_frame) do |join, inner_frame|
            inner_frame.concat(
              routing_frame.inner_join(
                target_frame,
                on: join.merge("mode_of_transport" => "mode_of_transport")
              )[%w[row sheet_name] + keys]
            )
          end
          Rover::DataFrame.new("sheet_name" => [], "row" => [], required_key => []).concat(
            Rover::DataFrame.new(full_frame[!full_frame[required_key].missing].to_a.uniq, types: frame_types)
          )
        end

        def hub_frame_data
          @hub_frame_data ||= Legacy::Hub.where(organization_id: Organizations.current_id)
            .joins(nexus: :country)
            .select("
              hubs.id as origin_hub_id,
              hubs.name as origin_name,
              terminal as origin_terminal,
              hub_code as origin_locode,
              countries.name as country_origin,
              hubs.id as destination_hub_id,
              hubs.name as destination_name,
              terminal as destination_terminal,
              hub_code as destination_locode,
              countries.name as country_destination,
              hub_type as mode_of_transport
            ")
        end

        def routing_frame
          @routing_frame ||= frame[ROUTING_ROW_KEYS & frame.keys]
        end

        def join_arguments
          { "row" => "row", "sheet_name" => "sheet_name" }
        end

        def frame_types
          { "origin_hub_id" => :object, "destination_hub_id" => :object }
        end

        def origin_joins
          @origin_joins ||= filter_joins(joins: [
            { "origin_locode" => "origin_locode" },
            { "origin" => "origin_name", "origin_terminal" => "origin_terminal", "country_origin" => "country_origin" }
          ])
        end

        def destination_joins
          @destination_joins ||= filter_joins(joins: [
            { "destination_locode" => "destination_locode" },
            { "destination" => "destination_name", "destination_terminal" => "destination_terminal", "country_destination" => "country_destination" }
          ])
        end

        def filter_joins(joins:)
          # rubocop:disable Rails/NegateInclude include is a Rover method, not standard rails include
          joins.map { |join| join.delete_if { |key, _val| !frame.include?(key) } }.reject(&:empty?)
          # rubocop:enable Rails/NegateInclude
        end

        def hub_frame
          @hub_frame ||= Rover::DataFrame.new(hub_frame_data, types: state.frame.types.merge(frame_types))
        end

        def base_frame
          @base_frame ||= Rover::DataFrame.new(frame[%w[row sheet_name]].to_a.uniq)
        end

        def origin_hub_frame
          @origin_hub_frame ||= hub_frame[%w[origin_hub_id origin_name origin_terminal origin_locode country_origin mode_of_transport]]
        end

        def destination_hub_frame
          @destination_hub_frame ||= hub_frame[%w[destination_hub_id destination_name destination_terminal destination_locode country_destination mode_of_transport]]
        end
      end
    end
  end
end
