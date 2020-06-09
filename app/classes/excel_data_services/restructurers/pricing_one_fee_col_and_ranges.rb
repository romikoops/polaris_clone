# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class PricingOneFeeColAndRanges < ExcelDataServices::Restructurers::Base
      ROWS_BY_CONNECTED_RANGES_GROUPING_KEYS =
        (ROWS_BY_PRICING_PARAMS_GROUPING_KEYS +
          %i[
            fee_code
            fee_name
          ]).freeze

      def perform # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        sheet_name = data[:sheet_name]
        restructurer_name = data[:restructurer_name]
        restructured_data = replace_nil_equivalents_with_nil(data[:rows_data])
        restructured_data = downcase_values(rows_data: restructured_data, keys: [:load_type, :mot])
        restructured_data = upcase_values(rows_data: restructured_data, keys: [:rate_basis])
        restructured_data.reject! { |row_data| row_data[:fee].blank? }
        restructured_data.each do |row_data|
          row_data.reverse_merge!(sheet_name: sheet_name,
                                  restructurer_name: restructurer_name)
          row_data[:internal] ||= false
        end

        restructured_data = trim_based_on_effective_date(restructured_data)

        grouped_data = group_by_params(restructured_data, ROWS_BY_CONNECTED_RANGES_GROUPING_KEYS)

        restructured_data = grouped_data.map do |group|
          result_row_data = group.first
          ranges_values = group.map do |row_data|
            next unless range_values?(row_data)

            extract_range_values(row_data)
          end
          ranges_values = ranges_values.compact

          if ranges_values.present?
            result_row_data.except!(:fee) # already inside range hash, called 'rate'.
            result_row_data[:range] = ranges_values
          end
          result_row_data.except!(:range_min, :range_max) # already inside range hash

          result_row_data
        end

        restructured_data = add_hub_names(restructured_data)
        restructured_data = sanitize_service_level_and_carrier(restructured_data)
        restructured_data = cut_based_on_date_overlaps(
          restructured_data,
          ROWS_BY_PRICING_PARAMS_GROUPING_KEYS - %i[effective_date expiration_date]
        )
        restructured_data = expand_fcl_to_all_sizes(restructured_data)
        restructured_data = group_by_params(restructured_data, ROWS_BY_PRICING_PARAMS_GROUPING_KEYS)

        { 'Pricing' => restructured_data }
      end

      private

      def trim_based_on_effective_date(restructured_data)
        grouped = group_by_params(
          restructured_data, ROWS_BY_CONNECTED_RANGES_GROUPING_KEYS - %i[effective_date expiration_date]
        )

        grouped.each do |group|
          group.sort_by { |row| row[:effective_date] }.each_cons(2) do |this_row, next_row|
            next if this_row[:expiration_date] < next_row[:effective_date] || this_row[:range_min].present?

            this_row[:expiration_date] = next_row[:effective_date] - 1.day
          end
        end

        grouped.flatten
      end

      def range_values?(row_data)
        row_data[:range_min] && row_data[:range_max]
      end

      def extract_range_values(row_data)
        { 'max' => row_data[:range_max], 'min' => row_data[:range_min], 'rate' => row_data[:fee] }
      end
    end
  end
end
