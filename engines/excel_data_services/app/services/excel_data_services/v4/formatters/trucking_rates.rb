# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class TruckingRates
        VERSION_KEYS = %w[organization_id sheet_name zone].freeze

        def initialize(data_frame:)
          @data_frame = data_frame
        end

        def rates
          Rover::DataFrame.new(formatted_rate_data)
        end

        private

        attr_reader :data_frame

        def formatted_rate_data
          rate_versions.map do |rate_version|
            rate_version.first_row.slice(*VERSION_KEYS).merge("rates" => RatesHash.new(rate_frame: rate_version).perform)
          end
        end

        def rate_versions
          @rate_versions ||= data_frame.group_by(valid_filter_keys)
        end

        def valid_filter_keys
          VERSION_KEYS & data_frame.keys
        end

        class RatesHash
          def initialize(rate_frame:)
            @rate_frame = rate_frame
          end

          def perform
            rate_frame["modifier"].uniq.to_a.each_with_object({}) do |modifier, result|
              result.merge!(build_modifier_section_from_row(modifier: modifier))
            end
          end

          private

          attr_reader :rate_frame

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
            rate_frame[rate_frame["modifier"] == modifier].to_a.uniq
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
