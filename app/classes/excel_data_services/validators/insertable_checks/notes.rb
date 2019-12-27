# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class Notes < ExcelDataServices::Validators::InsertableChecks::Base
        private

        def check_single_data(_row); end
      end
    end
  end
end
