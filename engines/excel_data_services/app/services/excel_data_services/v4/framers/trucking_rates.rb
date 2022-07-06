# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Framers
      class TruckingRates < ExcelDataServices::V4::Framers::Base
        STATE_COLUMNS = %w[distribute hub_id group_id organization_id row sheet_name].freeze

        def perform
          {
            "zones" => strip_coordinate_keys_from(data_frame: complete_zones),
            "default" => strip_coordinate_keys_from(data_frame: complete_metadata),
            "rates" => strip_coordinate_keys_from(data_frame: complete_rates),
            "fees" => strip_coordinate_keys_from(data_frame: complete_fees)
          }
        end

        private

        def rate_zone_frame
          @rate_zone_frame ||= Rover::DataFrame.new(
            rate_frame.filter("header" => "zone")[%w[row value sheet_name]].tap do |zone_inner_frame|
              prefixed_column_mapper(mapped_object: zone_inner_frame, header: "zone")
            end
          )
        end

        def zone_range_frame
          @zone_range_frame ||= ExcelDataServices::V4::Framers::SheetFramer.new(sheet_name: "Zones", frame: zone_values[zone_values["header"] != "identifier"]).perform
        end

        def rate_frame
          @rate_frame ||= frame[!frame["sheet_name"].in?(%w[Fees Zones])]
        end

        def metadata_frame
          @metadata_frame ||= frame.filter("target_frame" => "default")
        end

        def present_rate_frame
          @present_rate_frame ||= rate_frame[!rate_frame["value"].missing]
        end

        def rates_with_ranges
          @rates_with_ranges ||= rate_values_frame
            .inner_join(ranges_frame, on: { "rate_column" => "range_column", "sheet_name" => "sheet_name" })
            .inner_join(modifiers, on: { "rate_column" => "modifier_column", "sheet_name" => "sheet_name" })
            .inner_join(trucking_rate_defaults, on: { "sheet_name" => "sheet_name" })
        end

        def complete_rates
          @complete_rates ||= rates_with_ranges.inner_join(row_minimums, on: { "rate_row" => "row_minimum_row", "sheet_name" => "sheet_name" })
            .left_join(bracket_minimum, on: { "rate_column" => "bracket_minimum_column", "sheet_name" => "sheet_name" })
            .inner_join(rate_zone_frame, on: { "rate_row" => "zone_row", "sheet_name" => "sheet_name" })
            .inner_join(state_data, on: { "sheet_name" => "sheet_name" })
            .inner_join(rate_basis_frame, on: { "sheet_name" => "sheet_name" }).tap do |tapped_frame|
              tapped_frame["row"] = tapped_frame["rate_row"]
            end
        end

        def complete_fees
          @complete_fees ||= fees.inner_join(state_data, on: { "sheet_name" => "sheet_name" })
        end

        def complete_metadata
          @complete_metadata ||= metadata.inner_join(state_data, on: { "sheet_name" => "sheet_name" })
        end

        def complete_zones
          @complete_zones ||= zone_range_frame
            .inner_join(state_data, on: { "sheet_name" => "sheet_name" })
            .inner_join(rate_zones, on: { "zone" => "zone" })
            .inner_join(identifier, on: { "sheet_name" => "sheet_name" })
        end

        def ranges_frame
          @ranges_frame ||= Rover::DataFrame.new(
            present_rate_frame[present_rate_frame["header"] == "bracket"].to_a.flat_map do |range_row|
              range_row = prefixed_column_mapper(mapped_object: range_row, header: "range")
              range_row["range_min"], range_row["range_max"] = range_row.delete("range").split("-").map(&:strip).map(&:to_d)
              range_row
            end
          )
        end

        def rate_sheet_names
          @rate_sheet_names ||= rate_frame["sheet_name"].to_a.uniq
        end

        def rate_zones
          @rate_zones ||= rate_zone_frame[["zone"]].uniq
        end

        def rate_values_frame
          @rate_values_frame ||= Rover::DataFrame.new(
            present_rate_frame[present_rate_frame["header"] == "rate"].tap do |rate_inner_frame|
              prefixed_column_mapper(mapped_object: rate_inner_frame, header: "rate")
            end
          )
        end

        def bracket_minimum
          @bracket_minimum ||= Rover::DataFrame.new(
            present_rate_frame[present_rate_frame["header"] == "bracket_minimum"].tap do |bracket_min_inner_frame|
              prefixed_column_mapper(mapped_object: bracket_min_inner_frame, header: "bracket_minimum")
            end
          )
        end

        def row_minimums
          @row_minimums ||= Rover::DataFrame.new(
            rate_frame[rate_frame["header"] == "row_minimum"][%w[row value sheet_name]].tap do |row_min_inner_frame|
              prefixed_column_mapper(mapped_object: row_min_inner_frame, header: "row_minimum")
            end
          )
        end

        def modifiers
          @modifiers ||= Rover::DataFrame.new(
            present_rate_frame[present_rate_frame["header"] == "modifier"].tap do |modifier_inner_frame|
              prefixed_column_mapper(mapped_object: modifier_inner_frame, header: "modifier")
            end
          )
        end

        def metadata
          @metadata ||= Rover::DataFrame.new(
            rate_sheet_names.map do |rate_sheet_name|
              MetadataRows.new(sheet_name: rate_sheet_name, frame: metadata_frame).perform.inject({}) do |memo, row|
                row[row.delete("header")] = row.delete("value")
                memo.merge(row)
              end
            end
          )
        end

        def rate_basis_frame
          @rate_basis_frame ||= Rover::DataFrame.new(
            rate_frame.filter("header" => "rate_basis").to_a.map do |value|
              prefixed_column_mapper(mapped_object: value, header: "rate_basis")
            end
          )
        end

        def trucking_rate_defaults
          @trucking_rate_defaults ||= Rover::DataFrame.new(
            metadata[%w[sheet_name cargo_class]].to_a.map do |sheet_and_cargo_class|
              sheet_and_cargo_class["fee_code"] = "trucking_#{sheet_and_cargo_class.delete('cargo_class')}"
              sheet_and_cargo_class["fee_name"] = "Trucking rate"
              sheet_and_cargo_class["rate_type"] = "trucking_rate"
              sheet_and_cargo_class["mode_of_transport"] = "truck_carriage"
              sheet_and_cargo_class
            end
          )
        end

        def fees
          @fees ||= ExcelDataServices::V4::Framers::TruckingFees.new(frame: values.filter("target_frame" => "fees")).perform
        end

        def state_data
          @state_data ||= Rover::DataFrame.new(
            sheet_names.uniq.map do |rate_sheet_name|
              frame[(frame["sheet_name"] == rate_sheet_name) & (frame["header"].in?(STATE_COLUMNS))].to_a.inject({}) do |memo, row|
                row[row.delete("header")] = row.delete("value")
                memo.merge(row.except("row", "column", "target_frame"))
              end
            end
          )
        end

        def identifier
          @identifier ||= Rover::DataFrame.new(
            sheet_names.map do |sheet_name|
              {
                "identifier" => adjusted_identifier,
                "sheet_name" => sheet_name
              }
            end
          )
        end

        def sheet_names
          @sheet_names ||= frame["sheet_name"].to_a.uniq
        end

        def adjusted_identifier
          @adjusted_identifier ||= if raw_identifier == "postal_code" && frame_has_city_data?
            "postal_city"
          else
            raw_identifier
          end
        end

        def frame_has_city_data?
          frame.filter("header" => "city")["value"].any?(&:present?)
        end

        def raw_identifier
          @raw_identifier ||= frame.filter("header" => "identifier")["value"].to_a.first
        end

        def strip_coordinate_keys_from(data_frame:)
          data_frame[data_frame.keys.grep_v(/(_row|_column)$/)]
        end

        def zone_values
          @zone_values ||= frame.filter("target_frame" => "zones")
        end

        class MetadataRows
          METADATA_KEYS = %w[
            currency
            cbm_ratio
            scale
            rate_basis
            base
            truck_type
            load_type
            cargo_class
            direction
            carrier
            carrier_code
            service
            effective_date
            expiration_date
            load_meterage_ratio
            load_meterage_stackable_limit
            load_meterage_non_stackable_limit
            load_meterage_hard_limit
            load_meterage_stackable_type
            load_meterage_non_stackable_type
            mode_of_transport
          ].freeze

          def initialize(frame:, sheet_name:)
            @frame = frame
            @sheet_name = sheet_name
          end

          def perform
            sheet_frame[sheet_frame["header"].in?(METADATA_KEYS)].to_a
          end

          attr_reader :frame, :sheet_name

          def sheet_frame
            @sheet_frame ||= frame.filter("sheet_name" => sheet_name)
          end
        end
      end
    end
  end
end
