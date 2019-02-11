# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Insertability
      class Base
        include ExcelDataServices::DataValidator

        InsertabilityError = Class.new(ValidationError)

        def perform
          data.each do |single_data|
            begin
              check_data(single_data)
            rescue ValidationError => exception
              add_to_errors(row_nr: row.nr, reason: exception.message)
            end
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
