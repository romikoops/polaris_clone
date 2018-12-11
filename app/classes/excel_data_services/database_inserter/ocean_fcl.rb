# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class OceanFcl < Base
      private

      def pricing_details_with_dynamic_fee_cols_no_ranges(row)
        row[:fees].map do |fee_code, fee_value|
          { rate_basis: row[:rate_basis],
            rate: fee_value,
            min: 1 * fee_value,
            shipping_type: fee_code.upcase,
            currency_name: row[:currency].upcase,
            tenant_id: @tenant.id }
        end
      end

      def find_or_create_pricing_details_for_pricing(pricing, row, data_extraction_method)
        pricing_detail_params_arr = case data_extraction_method
                                    when 'dynamic_fee_cols_no_ranges'
                                      pricing_details_with_dynamic_fee_cols_no_ranges(row)
                                    when 'one_col_fee_and_ranges'
                                      pricing_details_with_one_col_fee_and_ranges(row)
                                    else
                                      raise InvalidDataExtractionMethodError, 'FCL data extraction method incorrect!'
                                    end

        pricing_detail_params_arr.each do |pricing_detail_params|
          pricing.pricing_details.find_or_create_by(pricing_detail_params)
        end
      end
    end
  end
end
