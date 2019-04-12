# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module ValidationErrors
      class InsertableChecks < ExcelDataServices::DataValidators::ValidationErrors::Base
        class HubsNotFound < InsertableChecks
        end
      end
    end
  end
end
