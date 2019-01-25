# frozen_string_literal: true

module ExcelDataServices
  module FileWriter
    class ChargeCategories < Base
      include ExcelDataServices::ChargeCategoryTool

      def initialize(tenant:, file_name:)
        super(tenant: tenant, file_name: file_name)
      end

      private

      attr_reader :mode_of_transport

      def load_and_prepare_data
        rows_data = []
        charge_categories = ChargeCategory.where(tenant_id: tenant.id)
        charge_categories&.each do |charge_category|
          rows_data << build_row_data(charge_category)
        end

        sort!(rows_data)

        { 'Sheet1' => rows_data }
      end

      def build_row_data(charge_category)
        {
          fee_code: charge_category.code.upcase,
          fee_name: charge_category.name,
          internal_code: nil
        }
      end

      def sort!(data)
        data.sort_by! do |h|
          h[:fee_code]
        end
      end

      def build_raw_headers(_sheet_name, _rows_data)
        VALID_CHARGE_HEADERS
      end
    end
  end
end
