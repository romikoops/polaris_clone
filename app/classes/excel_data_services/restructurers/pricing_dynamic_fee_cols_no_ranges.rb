# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class PricingDynamicFeeColsNoRanges < ExcelDataServices::Restructurers::Base
      def perform
        sheet_name = data[:sheet_name]
        restructurer_name = data[:restructurer_name]
        restructured_data = replace_nil_equivalents_with_nil(data[:rows_data])
        restructured_data = downcase_values(rows_data: restructured_data, keys: %i[load_type mot])
        restructured_data = upcase_values(rows_data: restructured_data, keys: %i[rate_basis])
        restructured_data = parse_dates(rows_data: restructured_data)

        restructured_data = restructured_data.map do |row_data|
          { sheet_name: sheet_name,
            restructurer_name: restructurer_name }.merge(row_data)
        end

        restructured_data = restructured_data.flat_map do |row_data|
          row_nr = row_data.delete(:row_nr)
          fee_keys = row_data.keys - standard_keys
          standard_part = row_data.slice(*standard_keys)
          fee_part = row_data.slice(*fee_keys)
          expand_dynamic_fees_to_individual_fees(standard_part, fee_part, row_nr)
        end

        restructured_data = add_hub_names(restructured_data)
        restructured_data = sanitize_service_level_and_carrier(restructured_data)

        restructured_data.each do |row_data|
          row_data[:internal] ||= false
          if row_data[:remarks]
            row_data[:notes] = extract_notes(row_data)
          end
        end
        restructured_data = cut_based_on_date_overlaps(
          restructured_data,
          ROWS_BY_PRICING_PARAMS_GROUPING_KEYS - %i[effective_date expiration_date]
        )
        restructured_data = expand_fcl_to_all_sizes(restructured_data)
        restructured_data = group_by_params(restructured_data, ROWS_BY_PRICING_PARAMS_GROUPING_KEYS)

        { 'Pricing' => restructured_data }
      end

      private

      def standard_keys
        ExcelDataServices::Validators::HeaderChecker::StaticHeadersForRestructurers::PRICING_DYNAMIC_FEE_COLS_NO_RANGES +
          ExcelDataServices::Validators::HeaderChecker::StaticHeadersForRestructurers::OPTIONAL_PRICING_DYNAMIC_FEE_COLS_NO_RANGES +
          IGNORED_KEYS
      end

      def expand_dynamic_fees_to_individual_fees(standard_part, fee_part, row_nr)
        result = fee_part.map do |fee_key, fee_value|
          next if fee_value.blank?

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
