# frozen_string_literal: true

module DataReader
  module Normanglobal
    class LocalChargesReader < DataReader::BaseReader
      private

      VALID_STATIC_HEADERS = %i(port
                                country
                                effective_date
                                expiration_date
                                counterpart_hub
                                counterpart_country
                                service_level
                                carrier
                                fee_code
                                fee
                                mot
                                load_type
                                direction
                                currency
                                rate_basis
                                minimum
                                maximum
                                base
                                ton
                                cbm
                                kg
                                item
                                shipment
                                bill
                                container
                                wm
                                range_min
                                range_max
                                dangerous).freeze

      def determine_data_extraction_method(headers)
      end

      def headers_valid?(headers)
        VALID_STATIC_HEADERS == headers
      end

      def correct_capitalization(row)
        col_names_to_capitalize = %i(port
                                     country
                                     counterpart_hub
                                     counterpart_country)

        col_names_to_capitalize.each do |col_name|
          row[col_name].capitalize!
        end

        col_names_containing_all = %i(counterpart_hub
                                      counterpart_country
                                      service_level
                                      carrier)

        col_names_containing_all.each do |col_name|
          row[col_name].downcase! if row[col_name].casecmp('all').zero?
        end

        col_names_to_downcase = %i(load_type
                                   mot
                                   direction)

        col_names_to_downcase.each do |col_name|
          row[col_name].downcase!
        end
      end

      def replace_nil_equivalents_with_nil(row)
        row.each do |k, v|
          row[k] = nil if v.is_a?(String) && ['n/a', '-', ''].include?(v.downcase)
        end
      end

      def sanitize_row(row)
        # 'roo' strips cells automatically...
        replace_nil_equivalents_with_nil(row)
        correct_capitalization(row)
      end

      def restructure_rows_data(rows_data)
        rows_data.each do |row|
          sanitize_row(row)
        end
      end
    end
  end
end
