# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class RouteHubs < ExcelDataServices::V2::Extractors::Base
        # All Sections that involve Itineraries willl need origin_hub_id and destination_hub_id. This class extracts those values based off data from the sheet and appends error messages if it is not found

        def frame_data
          Rover::DataFrame.new(frame[["row"]]) # Ensure we have columns to join on
            .left_join(final_origin_frame, on: { "row" => "row" }) # Join in all origin results that got an id
            .left_join(final_destination_frame, on: { "row" => "row" }) # Join in all destination results that got an id
            .to_a.uniq
        end

        def final_origin_frame
          @final_origin_frame ||= final_frame(target: "origin")
        end

        def final_destination_frame
          @final_destination_frame ||= final_frame(target: "destination")
        end

        def final_frame(target:)
          full_frame = Rover::DataFrame.new(
            send("#{target}_joins")
            .select { |join| frame.include?(join.keys.first) }
            .each_with_object(blank_frame) do |join, target_frame|
              target_frame.concat(frame[!frame[join.first.first].missing].left_join(send("#{target}_hub_frame"), on: join.merge("mode_of_transport" => "mode_of_transport")))
            end,
            types: frame_types
          )[["row", "#{target}_hub_id", "#{target}_name"]]

          full_frame[!full_frame["#{target}_hub_id"].missing]
        end

        def hub_frame_data
          Legacy::Hub.where(organization_id: Organizations.current_id).joins(nexus: :country).select("hubs.id as hub_id, hubs.name, terminal, hub_code, countries.name as country, hub_type as mode_of_transport")
        end

        def join_arguments
          { "row" => "row" }
        end

        def frame_types
          { "origin_hub_id" => :object, "destination_hub_id" => :object }
        end

        def origin_joins
          [
            { "origin_locode" => "origin_locode" },
            { "origin" => "origin_name", "origin_terminal" => "origin_terminal", "country_origin" => "country_origin" }
          ]
        end

        def destination_joins
          [
            { "destination_locode" => "destination_locode" },
            { "destination" => "destination_name", "destination_terminal" => "destination_terminal", "country_destination" => "country_destination" }
          ]
        end

        def hub_frame
          @hub_frame ||= Rover::DataFrame.new(hub_frame_data, types: state.frame.types.merge(frame_types))
        end

        def origin_hub_frame
          @origin_hub_frame ||= RouteHubFrame.new(frame: hub_frame.dup, target: "origin").perform
        end

        def destination_hub_frame
          @destination_hub_frame ||= RouteHubFrame.new(frame: hub_frame.dup, target: "destination").perform
        end

        def required_keys
          %w[origin_hub_id destination_hub_id]
        end

        def missing_hub_details(row:, key:)
          prefix = key.include?("origin") ? "origin" : "destination"

          row.values_at(prefix, "#{prefix}_locode", "country_#{prefix}").compact.join(", ")
        end

        def error_reason(row:, required_key:)
          "The hub '#{missing_hub_details(row: row, key: required_key)}' cannot be found. Please check that the information is entered correctly"
        end

        def append_errors_to_state
          required_keys.each { |required_key| append_required_key_errors(required_key: required_key) }
        end

        def append_required_key_errors(required_key:)
          extracted[extracted[required_key].missing].to_a.each do |error_row|
            append_error(row: error_row, required_key: required_key)
          end
        end

        def append_error(row:, required_key:)
          @state.errors << ExcelDataServices::DataFrames::Validators::Error.new(
            type: :warning,
            row_nr: row["row"],
            sheet_name: row["sheet_name"],
            reason: error_reason(row: row, required_key: required_key),
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        class RouteHubFrame
          # This class need to have the hubs sheet in both origin and destination formats in order to work. The inner class converts the frame keys to the necessary ones
          def initialize(frame:, target:)
            @frame = frame
            @target = target
          end

          attr_reader :frame, :target

          def perform
            frame["#{target}_locode"] = frame.delete("hub_code")
            frame["#{target}_name"] = frame.delete("name")
            frame["#{target}_terminal"] = frame.delete("terminal")
            frame["#{target}_hub_id"] = frame.delete("hub_id")
            frame["country_#{target}"] = frame.delete("country")
            frame
          end
        end
      end
    end
  end
end
