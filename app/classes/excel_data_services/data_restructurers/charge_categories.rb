# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurers
    class ChargeCategories < Base
      def perform
        { 'ChargeCategories' => data[:rows_data] }
      end
    end
  end
end
