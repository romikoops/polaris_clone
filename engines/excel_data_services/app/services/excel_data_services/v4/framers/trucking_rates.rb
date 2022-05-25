# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Framers
      class TruckingRates < ExcelDataServices::V4::Framers::Base
        STATE_COLUMNS = %w[distribute hub_id group_id organization_id row sheet_name].freeze

        def perform
          zone_range_frame
            .inner_join(rate_zone_frame, on: { "zone" => "zone" })
            .inner_join(merged_rates_with_metadata, on: { "zone_row" => "rate_row", "sheet_name" => "sheet_name" })
            .concat(fees)
            .inner_join(state_data, on: { "sheet_name" => "sheet_name" })
            .inner_join(identifier, on: { "sheet_name" => "sheet_name" })
        end

        def rate_zone_frame
          @rate_zone_frame ||= Rover::DataFrame.new(
            rate_frame[rate_frame["header"] == "zone"][%w[row value sheet_name]].tap do |zone_inner_frame|
              prefixed_column_mapper(mapped_object: zone_inner_frame, header: "zone")
            end
          )
        end

        def zone_range_frame
          @zone_range_frame ||= ExcelDataServices::V4::Framers::SheetFramer.new(sheet_name: "Zones", frame: values[values["header"] != "identifier"]).perform
        end

        def rate_frame
          @rate_frame ||= frame[!frame["sheet_name"].in?(%w[Fees Zones])]
        end

        def present_rate_frame
          @present_rate_frame ||= rate_frame[!rate_frame["value"].missing]
        end

        def merged_rates_with_metadata
          @merged_rates_with_metadata ||= rates_with_ranges_and_minimum
            .inner_join(metadata, on: { "sheet_name" => "sheet_name" })
        end

        def rates_with_ranges
          @rates_with_ranges ||= rate_values_frame
            .inner_join(ranges_frame, on: { "rate_column" => "range_column", "sheet_name" => "sheet_name" })
            .inner_join(modifiers, on: { "rate_column" => "modifier_column", "sheet_name" => "sheet_name" })
            .inner_join(trucking_rate_defaults, on: { "sheet_name" => "sheet_name" })
        end

        def rates_with_ranges_and_minimum
          @rates_with_ranges_and_minimum ||= rates_with_ranges.inner_join(row_minimums, on: { "rate_row" => "row_minimum_row", "sheet_name" => "sheet_name" })
            .left_join(bracket_minimum, on: { "rate_column" => "bracket_minimum_column", "sheet_name" => "sheet_name" })
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
              MetadataRows.new(sheet_name: rate_sheet_name, frame: rate_frame).perform.inject({}) do |memo, row|
                row[row.delete("header")] = row.delete("value")
                memo.merge(row)
              end
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
          @fees ||= ExcelDataServices::V4::Framers::TruckingFees.new(frame: values).perform
        end

        def state_data
          @state_data ||= Rover::DataFrame.new(
            frame["sheet_name"].to_a.uniq.map do |rate_sheet_name|
              frame[(frame["sheet_name"] == rate_sheet_name) & (frame["header"].in?(STATE_COLUMNS))].to_a.inject({}) do |memo, row|
                row[row.delete("header")] = row.delete("value")
                memo.merge(row)
              end
            end
          )
        end

        def identifier
          @identifier ||= Rover::DataFrame.new(
            frame["sheet_name"].to_a.uniq.product(frame[frame["header"] == "identifier"]["value"].to_a).map do |sheet_name, identifier|
              {
                "identifier" => identifier,
                "sheet_name" => sheet_name
              }
            end
          )
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
