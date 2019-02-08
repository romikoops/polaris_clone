# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Insertability
      class Base
        include ExcelDataServices::DataValidator

        InsertabilityError = Class.new(ValidationError)

        def perform
          data.each do |restructured_row_data|
            check_data(restructured_row_data)
          end

          errors
        end

        private

        def check_data(single_data)
          raise NotImplementedError, "This method must be implemented in #{self.class.name}."
        end
      end
    end
  end
end
