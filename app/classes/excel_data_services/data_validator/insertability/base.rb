# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Insertability
      class Base
        InsertabilityError = Class.new(StandardError)

        def self.validate(options)
          new(options).perform
        end

        def initialize(data:, tenant:)
          @data = data
          @tenant = tenant
          @errors = []
        end

        def perform
          data.each do |_sheet_name, sheet_data|
            sheet_data[:rows_data].each_with_index do |row_data, i|
              row = ExcelDataServices::Row::Base.new(row_data: row_data, tenant: tenant)

              begin
                if block_given?
                  yield(row)
                else
                  raise NotImplementedError, "This method is either not implemented in #{self.class.name}" \
                                             ", or doesn't provide a block to its superclass method."
                end
              rescue InsertabilityError => exception
                # TODO: i + 1 is most likely not the correct row number...
                add_to_errors(row_nr: i + 1, reason: exception.message)
              end
            end
          end

          errors
        end

        private

        attr_reader :data, :tenant, :errors

        def add_to_errors(row_nr:, reason:)
          @errors << { row_nr: row_nr,
                       reason: reason }
        end
      end
    end
  end
end
