# frozen_string_literal: true

module ExcelDataServices
  module FileParser
    class LocalCharges < Base
      include ExcelDataServices::LocalChargesTool

      def initialize(tenant:, file_or_path:)
        super

        @missing_value_errors = []
      end

      private

      def build_valid_headers(_data_extraction_method)
        VALID_STATIC_HEADERS
      end

      def correct_capitalization(row_data)
        col_names_to_capitalize = %i(hub
                                     country
                                     counterpart_hub
                                     counterpart_country)

        col_names_to_capitalize.each do |col_name|
          row_data[col_name] = row_data[col_name]&.titleize
        end

        col_names_containing_all = %i(counterpart_hub
                                      counterpart_country
                                      service_level
                                      carrier)

        col_names_containing_all.each do |col_name|
          row_data[col_name].downcase! if row_data[col_name]&.casecmp('all')&.zero?
        end

        col_names_to_downcase = %i(load_type
                                   mot
                                   direction)

        col_names_to_downcase.each do |col_name|
          row_data[col_name]&.downcase!
        end

        row_data
      end

      def replace_nil_equivalents_with_nil(row_data)
        row_data.each do |k, v|
          row_data[k] = nil if v.is_a?(String) && ['n/a', '-', ''].include?(v.downcase)
        end

        row_data
      end

      def sanitize_row_data(row_data)
        row_data = strip_whitespaces(row_data)
        row_data = replace_nil_equivalents_with_nil(row_data)
        correct_capitalization(row_data)
      end
    end
  end
end
