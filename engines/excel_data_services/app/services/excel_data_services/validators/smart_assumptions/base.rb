# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module SmartAssumptions
      class Base < ExcelDataServices::Validators::Base
        alias_method :chunked_data, :data

        def perform
          chunked_data.flatten.each do |single_data|
            row = ExcelDataServices::Rows::Base.get(klass_identifier).new(
              row_data: single_data, organization: organization
            )
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
