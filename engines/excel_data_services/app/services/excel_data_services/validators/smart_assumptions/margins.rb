# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module SmartAssumptions
      class Margins < ExcelDataServices::Validators::MissingValues::Base
        private

        def check_single_data(_row)
        end
      end
    end
  end
end
