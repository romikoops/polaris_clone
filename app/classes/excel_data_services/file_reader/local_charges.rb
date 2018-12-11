# frozen_string_literal: true

module ExcelDataServices
  module FileReader
    class LocalCharges < Base
      include ExcelDataServices::LocalChargesTool
      include DataRestructurer::LocalCharges

      private

      def build_valid_headers(_data_extraction_method)
        VALID_STATIC_HEADERS
      end

      def correct_capitalization(row)
        col_names_to_capitalize = %i(hub
                                     country
                                     counterpart_hub
                                     counterpart_country)

        col_names_to_capitalize.each do |col_name|
          row[col_name] = row[col_name].titleize
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

      def sanitize_rows_data(rows_data)
        rows_data.each do |row|
          # 'roo' strips cells automatically...
          replace_nil_equivalents_with_nil(row)
          correct_capitalization(row)
        end
      end
    end
  end
end
