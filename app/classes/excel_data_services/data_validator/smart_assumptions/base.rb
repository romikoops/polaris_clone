# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module SmartAssumptions
      class Base
        include ExcelDataServices::DataValidator

        def perform
          data.each do |single_data|
            row = ExcelDataServices::Row.get(klass_identifier).new(row_data: single_data, tenant: tenant)
            check_data(row)
          rescue ExcelDataServices::DataValidator::ValidationError::Base => exception
            add_to_errors(row_nr: row.nr, reason: exception.message)
          end

          errors
        end

        private

        def check_data(_single_data)
          raise NotImplementedError, "This method must be implemented in #{self.class.name}."
        end
      end
    end
  end
end
