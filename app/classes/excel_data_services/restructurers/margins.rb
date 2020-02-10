# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class Margins < ExcelDataServices::Restructurers::Base
      def perform
        sheet_name = data[:sheet_name]
        restructurer_name = data[:restructurer_name]
        restructured_data = replace_nil_equivalents_with_nil(data[:rows_data])
        restructured_data = downcase_load_types(restructured_data)
        restructured_data = sanitize_service_level_and_carrier(restructured_data)

        restructured_data = restructured_data.map do |row_data|
          { sheet_name: sheet_name,
            restructurer_name: restructurer_name }.merge(row_data)
        end

        restructured_data = group_by_params(restructured_data, ROWS_BY_MARGIN_PARAMS_GROUPING_KEYS)

        { 'Margins' => restructured_data }
      end
    end
  end
end
