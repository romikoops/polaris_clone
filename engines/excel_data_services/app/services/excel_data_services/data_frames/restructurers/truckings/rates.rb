# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Truckings
        class Rates < ExcelDataServices::DataFrames::Restructurers::Base
          GROUPING_KEYS = %w[cargo_class carriage truck_type zone].freeze
          def restructured_data
            groupings.map do |grouping|
              build_rate_from_row(
                cargo_class: grouping["cargo_class"],
                carriage: grouping["carriage"],
                truck_type: grouping["truck_type"],
                zone: grouping["zone"]
              )
            end
          end

          def build_rate_from_row(cargo_class:, carriage:, truck_type:, zone:)
            results = build_modifier_sections_from_sub_frame(
              sub_frame: sub_frames(
                cargo_class: cargo_class, carriage: carriage, truck_type: truck_type, zone: zone
              )
            )

            { "rates" => results, "cargo_class" => cargo_class, "carriage" => carriage, "truck_type" => truck_type, "zone" => zone }
          end

          def build_modifier_sections_from_sub_frame(sub_frame:)
            sub_frame["modifier"].uniq.to_a.each_with_object({}) do |modifier, result|
              result.merge!(build_modifier_section_from_row(sub_frame: sub_frame, modifier: modifier))
            end
          end

          def build_modifier_section_from_row(sub_frame:, modifier:)
            modifier_rows = modifier_results(sub_frame: sub_frame, modifier: modifier)

            { modifier.to_s => modifier_rows.map { |row| build_rate_hash(row: row) }.uniq }
          end

          def build_rate_hash(row:)
            min_max = bracket(row: row)
            data = trimmed_row(row: row)
            {
              rate: row.slice("currency", "rate_basis", "base", "value")
            }.merge(min_max).merge(min_value_attributes(row: data))
          end

          def sub_frames(cargo_class:, carriage:, truck_type:, zone:)
            frame[(frame["cargo_class"] == cargo_class) & (frame["carriage"] == carriage) & (frame["truck_type"] == truck_type) & (frame["zone"] == zone)]
          end

          def modifier_results(sub_frame:, modifier:)
            sub_frame[sub_frame["modifier"] == modifier].to_a.uniq
          end

          def groupings
            @groupings ||= frame[GROUPING_KEYS].to_a.uniq
          end

          def min_value_attributes(row:)
            { min_value: row.values_at("zone_minimum", "bracket_minimum").compact.max }
          end

          def bracket(row:)
            {
              "min_#{row['modifier']}" => row["min"],
              "max_#{row['modifier']}" => row["max"]
            }
          end
        end
      end
    end
  end
end
