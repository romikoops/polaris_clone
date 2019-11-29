# frozen_string_literal: true

module ExcelDataServices
  module FileWriters
    class ChargeCategories < ExcelDataServices::FileWriters::Base
      private

      attr_reader :mode_of_transport

      def load_and_prepare_data
        charge_categories = ChargeCategory.where(tenant_id: tenant.id, cargo_unit_id: nil, sandbox: @sandbox)
        rows_data = charge_categories&.map do |charge_category|
          build_row_data(charge_category)
        end

        sort!(rows_data)

        { 'Charge Categories' => rows_data }
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
          h[:fee_code] || ''
        end
      end

      def build_raw_headers(_sheet_name, _rows_data)
        ExcelDataServices::DataValidators::HeaderChecker::StaticHeadersForDataRestructurers::CHARGE_CATEGORIES
      end
    end
  end
end
