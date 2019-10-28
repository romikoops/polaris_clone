# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module MissingValues
      class Base < ExcelDataServices::DataValidators::Base
        alias chunked_data data

        def perform
          chunked_data.flatten.each do |single_data|
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
