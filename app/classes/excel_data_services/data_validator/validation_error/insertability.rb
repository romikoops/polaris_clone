# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module ValidationError
      class Insertability < ExcelDataServices::DataValidator::ValidationError::Base
        class HubsNotFound < Insertability
        end
      end
    end
  end
end
