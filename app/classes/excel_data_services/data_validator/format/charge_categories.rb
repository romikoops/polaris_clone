# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Format
      class ChargeCategories < ExcelDataServices::DataValidator::Format::Base
        private

        def check_row(row)
          # raise NotImplementedError
        end

        def build_valid_headers(_data_extraction_method)
          %i(internal_code
             fee_code
             fee_name)
        end
      end
    end
  end
end
