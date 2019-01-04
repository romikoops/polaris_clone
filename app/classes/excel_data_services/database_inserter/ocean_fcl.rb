# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class OceanFcl < Base
      private

      def pricing_detail_params_by_dynamic_fee_cols_no_ranges(row)
        params = row[:fees].map do |fee_code, fee_value|
          next unless fee_value

          ChargeCategory.from_code(fee_code, tenant_id = tenant.id)

          {
            range: nil,
            rate_basis: row[:rate_basis],
            rate: fee_value,
            min: fee_value,
            shipping_type: fee_code.upcase,
            currency_name: row[:currency].upcase,
            tenant_id: @tenant.id
          }
        end

        params.compact
      end

      def build_pricing_detail_params_for_pricing(row, data_extraction_method)
        case data_extraction_method
        when 'dynamic_fee_cols_no_ranges'
          pricing_detail_params_by_dynamic_fee_cols_no_ranges(row)
        when 'one_col_fee_and_ranges'
          pricing_detail_params_by_one_col_fee_and_ranges(row)
        else
          raise InvalidDataExtractionMethodError, 'FCL data extraction method incorrect!'
        end
      end
    end
  end
end
