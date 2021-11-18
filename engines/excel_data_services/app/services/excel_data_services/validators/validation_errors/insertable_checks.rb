# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module ValidationErrors
      class InsertableChecks < ExcelDataServices::Validators::ValidationErrors::Base
        class HubsNotFound < InsertableChecks
        end

        class DuplicateDataFound < InsertableChecks
        end

        class RequiredDataMissing < InsertableChecks
        end
      end
    end
  end
end
