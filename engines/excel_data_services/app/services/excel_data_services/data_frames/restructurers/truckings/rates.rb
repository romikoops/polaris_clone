# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Truckings
        class Rates < ExcelDataServices::DataFrames::Restructurers::Base
          def restructured_data
            groupings.map do |grouping|
              build_rate_from_row(
                sheet_name: grouping["sheet_name"],
                zone: grouping["zone"]
              )
            end
          end

          def build_rate_from_row(sheet_name:, zone:)
            results = build_modifier_sections_from_sub_frame(
              sub_frame: sub_frames_by_sheet_and_zone(sheet_name: sheet_name, zone: zone)
            )
            {"rates" => results, "sheet_name" => sheet_name, "zone" => zone}
          end

          def build_modifier_sections_from_sub_frame(sub_frame:)
            sub_frame["modifier"].uniq.to_a.each_with_object({}) do |modifier, result|
              result.merge!(build_modifier_section_from_row(sub_frame: sub_frame, modifier: modifier))
            end
          end

          def build_modifier_section_from_row(sub_frame:, modifier:)
            modifier_rows = modifier_results(sub_frame: sub_frame, modifier: modifier)
            {modifier.to_s => modifier_rows.map { |row| build_rate_hash(row: row) }.uniq}
          end

          def build_rate_hash(row:)
            min_max = bracket(row: row)
            data = trimmed_row(row: row)
            {
              rate: row.slice("currency", "rate_basis", "base", "value")
            }.merge(min_max).merge(min_value_attributes(row: data))
          end

          def sub_frames_by_sheet_and_zone(sheet_name:, zone:)
            frame[(frame["sheet_name"] == sheet_name) & (frame["zone"] == zone)]
          end

          def modifier_results(sub_frame:, modifier:)
            sub_frame[sub_frame["modifier"] == modifier].to_a.uniq
          end

          def groupings
            @groupings ||= frame[%w[sheet_name zone]].to_a.uniq
          end

          def min_value_attributes(row:)
            {min_value: row.values_at("zone_minimum", "bracket_minimum").compact.max}
          end

          def bracket(row:)
            {
              "min_#{row["modifier"]}" => row["min"],
              "max_#{row["modifier"]}" => row["max"]
            }
          end
        end
      end
    end
  end
end
