# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class MaxDimensions < ExcelDataServices::Validators::InsertableChecks::Base
        private

        def check_single_data(row); end
      end
    end
  end
end
