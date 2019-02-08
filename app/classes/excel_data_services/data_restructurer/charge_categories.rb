# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurer
    module ChargeCategories # TODO: class ChargeCategories < Base
      def build_charge_params(data)
        data.values.flat_map do |per_sheet_values|
          per_sheet_values[:rows_data]
        end
      end

      def restructure_data(data)
        build_charge_params(data)
      end
    end
  end
end
