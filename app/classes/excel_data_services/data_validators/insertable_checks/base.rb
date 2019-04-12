# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module InsertableChecks
      class Base < parent::Base
        alias chunked_data data

        def perform
          flattened_data = chunked_data.flatten

          check_all_data(flattened_data) if respond_to?(:check_all_data, true)

          flattened_data.each do |single_data|
            row = ExcelDataServices::Rows::Base.get(klass_identifier).new(row_data: single_data, tenant: tenant)
            check_single_data(row)
          end
        end

        private

        def check_single_data(_single_data)
          raise NotImplementedError, "This method must be implemented in #{self.class.name}."
        end
      end
    end
  end
end
