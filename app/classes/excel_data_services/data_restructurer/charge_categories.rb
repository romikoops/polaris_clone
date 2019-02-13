# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurer
    class ChargeCategories < Base
      def perform
        data.values.flat_map do |per_sheet_values|
          per_sheet_values[:rows_data]
        end
      end
    end
  end
end
