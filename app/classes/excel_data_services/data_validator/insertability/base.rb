# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Insertability
      class Base
        include ExcelDataServices::DataValidator

        InsertabilityError = Class.new(ValidationError)

        alias chunked_data data

        def perform
          chunked_data.flatten.each do |single_data|
            row = ExcelDataServices::Row.get(klass_identifier).new(row_data: single_data, tenant: tenant)
            check_single_row(row)
          rescue ValidationError => exception
            add_to_errors(row_nr: row.nr, reason: exception.message)
          end

          errors
        end

        private

        def check_single_row(_single_data)
          raise NotImplementedError, "This method must be implemented in #{self.class.name}."
        end

        def items_have_differing_uuids?(items, row_uuid)
          items.where.not(uuid: row_uuid).any?
        end
      end
    end
  end
end
