# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class Trucking < ExcelDataServices::V4::Formatters::Base
        VERSION_KEYS = %w[hub_id postal_code locode city distance truck_type carriage cargo_class carrier service].freeze

        def insertable_data
          rate_versions.map do |rate_version|
            TruckingFromFrame.new(frame: frame.filter(rate_version), state: state).perform
          end
        end

        def rate_versions
          @rate_versions ||= frame[frame["rate_type"] == "trucking_rate"][valid_filter_keys].to_a.uniq
        end

        def valid_filter_keys
          VERSION_KEYS & frame.keys
        end

        class TruckingFromFrame
          LOAD_METERAGE_KEYS = %w[
            load_meterage_ratio
            load_meterage_stackable_type
            load_meterage_non_stackable_type
            load_meterage_hard_limit
            load_meterage_stackable_limit
            load_meterage_non_stackable_limit
          ].freeze
          MODEL_ATTR_KEYS = %w[
            cargo_class
            carriage
            cbm_ratio
            load_type
            modifier
            truck_type
            group_id
            hub_id
            organization_id
            tenant_vehicle_id
          ].freeze

          def initialize(frame:, state:)
            @frame = frame
            @state = state
          end

          attr_reader :frame, :state

          def perform
            row.slice(*MODEL_ATTR_KEYS).merge(
              "rates" => rates,
              "fees" => fees,
              "load_meterage" => load_meterage,
              "validity" => "[#{row['effective_date'].to_date}, #{row['expiration_date'].to_date})",
              "location_id" => row["trucking_location_id"]
            )
          end

          def row
            @row ||= frame.to_a.first
          end

          def rates
            RatesHash.new(frame: frame.filter({ "rate_type" => "trucking_rate" })).perform
          end

          def fees
            JsonFeeStructure.new(frame: frame.filter({ "rate_type" => "trucking_fee" })).perform
          end

          def load_meterage
            row.slice(*LOAD_METERAGE_KEYS)
              .transform_keys { |key| key.delete_prefix("load_meterage_") }
              .tap do |datum|
                datum["hard_limit"] = datum["hard_limit"].present?
                datum["stackable_type"] ||= legacy_load_meterage_limit_type
                datum["stackable_limit"] ||= row["load_meterage_#{legacy_load_meterage_limit_type}"]
              end
          end

          def legacy_load_meterage_limit_type
            @legacy_load_meterage_limit_type ||= %w[area height].find { |type| row["load_meterage_#{type}"].present? }
          end
        end

        class RatesHash
          def initialize(frame:)
            @frame = frame
          end

          def perform
            frame["modifier"].uniq.to_a.each_with_object({}) do |modifier, result|
              result.merge!(build_modifier_section_from_row(modifier: modifier))
            end
          end

          private

          attr_reader :frame

          def build_modifier_section_from_row(modifier:)
            modifier_rows = modifier_results(modifier: modifier)

            { modifier.to_s => modifier_rows.map { |row| build_rate_hash(row: row) }.uniq }
          end

          def build_rate_hash(row:)
            min_max = bracket(row: row)
            {
              "rate" => row.slice("currency", "rate_basis", "base").merge("rate" => row["rate"].to_f)
            }.merge(min_max).merge(min_value_attributes(row: row.compact))
          end

          def modifier_results(modifier:)
            frame[frame["modifier"] == modifier].to_a.uniq
          end

          def min_value_attributes(row:)
            { "min_value" => row.values_at("row_minimum", "bracket_minimum").compact.max.to_f }
          end

          def bracket(row:)
            {
              "min_#{row['modifier']}" => row["range_min"],
              "max_#{row['modifier']}" => row["range_max"]
            }
          end
        end
      end
    end
  end
end
