# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module MissingValues
      class Employees < ExcelDataServices::DataValidators::MissingValues::Base
        private

        def check_single_data(_row)
        end
      end
    end
  end
end
