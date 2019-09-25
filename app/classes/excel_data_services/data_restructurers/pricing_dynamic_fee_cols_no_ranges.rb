# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurers
    class PricingDynamicFeeColsNoRanges < Base
      def perform # rubocop:disable Metrics/AbcSize
        sheet_name = data[:sheet_name]
        data_restructurer_name = data[:data_restructurer_name]
        restructured_data = replace_nil_equivalents_with_nil(data[:rows_data])
        restructured_data = downcase_load_types(restructured_data)

        restructured_data = restructured_data.map do |row_data|
          { sheet_name: sheet_name,
            data_restructurer_name: data_restructurer_name }.merge(row_data)
        end

        restructured_data = restructured_data.flat_map do |row_data|
          row_nr = row_data.delete(:row_nr)
          standard_keys, fee_keys = row_data.keys.slice_after(:currency).to_a
          standard_part = row_data.slice(*standard_keys)
          fee_part = row_data.slice(*fee_keys)

          expand_dynamic_fees_to_individual_fees(standard_part, fee_part, row_nr)
        end

        restructured_data = add_hub_names(restructured_data)
        restructured_data = downcase_load_types(restructured_data)
        restructured_data = expand_based_on_date_overlaps(restructured_data)
        restructured_data = expand_fcl_to_all_sizes(restructured_data)
        restructured_data = group_by_params(restructured_data, ROWS_BY_PRICING_PARAMS_GROUPING_KEYS)

        { 'Pricing' => restructured_data }
      end

      private

      def expand_dynamic_fees_to_individual_fees(standard_part, fee_part, row_nr)
        result = fee_part.map do |fee_key, fee_value|
          next unless fee_value.present?

          standard_part.merge(
            fee_code: fee_key.to_s.upcase,
            fee_name: fee_key.to_s.capitalize,
            fee: fee_value,
            fee_min: fee_value
          ).merge(row_nr: row_nr)
        end

        result.compact
      end
    end
  end
end
