# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurers
    class PricingOneColFeeAndRanges < Base
      ROWS_BY_CONNECTED_RANGES_GROUPING_KEYS =
        (ROWS_BY_PRICING_PARAMS_GROUPING_KEYS +
          %i(
            fee_code
            fee_name
          )).freeze

      def perform # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        sheet_name = data[:sheet_name]
        data_restructurer_name = data[:data_restructurer_name]
        restructured_data = replace_nil_equivalents_with_nil(data[:rows_data])
        restructured_data = downcase_load_types(restructured_data)
        restructured_data.reject! { |row_data| row_data[:fee].blank? }

        restructured_data = restructured_data.map do |row_data|
          { sheet_name: sheet_name,
            data_restructurer_name: data_restructurer_name }.merge(row_data)
        end

        grouped_data = group_by_connected_ranges(restructured_data)

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
        restructured_data = expand_fcl_to_all_sizes(restructured_data)

        # Necessary until we get rid of structure "one pricing<->many pricing_details"
        restructured_data = group_by_pricing_params(restructured_data)

        { 'Pricing' => restructured_data }
      end

      private

      def group_by_connected_ranges(rows_data)
        rows_data.group_by { |row_data| row_data.slice(*ROWS_BY_CONNECTED_RANGES_GROUPING_KEYS) }.values
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
