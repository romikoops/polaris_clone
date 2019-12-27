# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class LocalCharges < ExcelDataServices::Restructurers::Base # rubocop:disable Metrics/ClassLength
      COLS_CONTAINING_ALL = %i[
        counterpart_hub
        counterpart_country
        service_level
        carrier
      ].freeze

      COLS_TO_DOWNCASE = %i[
        load_type
        mot
        direction
      ].freeze

      ROW_IDENTIFIERS = %i[
        hub
        country
        effective_date
        expiration_date
        counterpart_hub
        counterpart_country
        service_level
        carrier
        mot
        load_type
        direction
        dangerous
      ].freeze

      def perform
        rows_data = replace_nil_equivalents_with_nil(data[:rows_data])
        rows_data = correct_capitalization(rows_data)
        sanitize_service_level!(rows_data)
        rows_data = expand_fcl_to_all_sizes(rows_data)
        rows_data = cut_based_on_date_overlaps(rows_data, ROW_IDENTIFIERS - %i[effective_date expiration_date])
        rows_chunked_by_identifier = rows_data.group_by { |row| row.slice(*ROW_IDENTIFIERS) }.values
        rows_chunked_by_identifier_and_sorted_ranges = rows_chunked_by_identifier.map do |rows|
          rows_chunked_by_ranges = rows.group_by { |row| range_identifier(row) }.values
          sort_chunks_by_range_min(rows_chunked_by_ranges)
        end

        charges_data = build_charges_data(rows_chunked_by_identifier_and_sorted_ranges)
        add_hub_names(charges_data)

        { 'LocalCharges' => charges_data }
      end

      private

      def correct_capitalization(rows_data)
        rows_data.map do |row_data|
          COLS_CONTAINING_ALL.each do |col_name|
            row_data[col_name].downcase! if row_data[col_name]&.casecmp?('all')
          end

          COLS_TO_DOWNCASE.each do |col_name|
            row_data[col_name]&.downcase!
          end

          row_data
        end
      end

      def sanitize_service_level!(rows_data)
        rows_data.each do |row_data|
          row_data[:service_level] ||= 'standard'
        end
      end

      def range_identifier(row)
        { rate_basis: row[:rate_basis].upcase, fee_code: row[:fee_code].upcase }
      end

      def sort_chunks_by_range_min(chunked_data)
        chunked_data.map { |range_chunks| range_chunks.sort_by { |row| row[:range_min] } }
      end

      def build_charges_data(chunked_raw_data)
        chunked_raw_data.map do |data_per_identifier|
          data_without_fees = data_per_identifier.dig(0, 0).slice(*ROW_IDENTIFIERS)
          data_with_fees = data_without_fees.merge(fees: {})

          data_per_identifier.each do |data_per_ranges|
            ranges_obj = { range: reduce_ranges_into_one_obj(data_per_ranges) }
            charge_data = data_per_ranges.first
            fee_code = charge_data[:fee_code]
            fees_obj = { fee_code => standard_charge_params(charge_data) }

            if ranges_obj[:range]
              fees_obj[fee_code].merge!(ranges_obj)
            else
              rate_basis = RateBasis.get_internal_key(charge_data[:rate_basis].upcase)
              fees_obj[fee_code].merge!(
                specific_charge_params(rate_basis, charge_data)
              )
            end

            data_with_fees[:row_nr] = add_row_numbers(data_with_fees[:row_nr], data_per_ranges)

            data_with_fees[:fees].merge!(fees_obj)
          end

          data_with_fees
        end
      end

      def reduce_ranges_into_one_obj(data_per_ranges)
        ranges_obj = data_per_ranges.map do |single_data|
          next unless includes_range?(single_data)

          rate_basis = RateBasis.get_internal_key(single_data[:rate_basis].upcase)

          { currency: single_data[:currency],
            min: single_data[:range_min],
            max: single_data[:range_max],
            **specific_charge_params(rate_basis, single_data) }
        end

        ranges_obj.compact.empty? ? nil : ranges_obj
      end

      def includes_range?(row)
        row[:range_min] && row[:range_max]
      end

      def standard_charge_params(charge_data)
        { currency: charge_data[:currency],
          key: charge_data[:fee_code],
          min: charge_data[:minimum],
          max: charge_data[:maximum],
          name: charge_data[:fee],
          rate_basis: charge_data[:rate_basis].upcase }
      end

      def specific_charge_params(rate_basis, single_data) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        return { value: single_data[:kg], base: single_data[:base] } if rate_basis == 'PER_X_KG_FLAT'
        return { value: single_data[:ton], base: single_data[:base] } if rate_basis == 'PER_SHIPMENT_TON'

        if rate_basis == 'PER_UNIT_TON_CBM_RANGE' && (single_data[:cbm] && single_data[:ton])
          raise StandardError, "There should only be one value for rate_basis 'PER_UNIT_TON_CBM_RANGE'."
        end

        keys = rate_basis.downcase.split('_')[1..-1].map(&:to_sym)
        value_obj = {}
        keys.each { |key| value_obj[key] = single_data[key] if single_data[key] }
        if value_obj.size == 1 && !keys.include?(:range) && rate_basis != 'PER_TON'
          value_obj[:value] = value_obj.delete(value_obj.keys.first)
        end

        value_obj
      end

      def add_row_numbers(row_numbers, data_per_ranges)
        (row_numbers.present? ? row_numbers + ', ' : '') +
          data_per_ranges.map { |single_data| single_data[:row_nr] }.join(', ')
      end

      def add_hub_names(charges_data)
        charges_data.each do |params|
          hub_name = append_hub_suffix(params[:hub], params[:mot])
          if params[:counterpart_hub] && !params[:counterpart_hub].casecmp?('all')
            counterpart_hub_name = append_hub_suffix(params[:counterpart_hub], params[:mot])
          end
          params[:hub_name] = hub_name
          params[:counterpart_hub_name] = counterpart_hub_name
        end
      end
    end
  end
end
