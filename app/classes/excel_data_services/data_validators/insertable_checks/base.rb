# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module InsertableChecks
      class Base < ExcelDataServices::DataValidators::Base
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

        def check_correct_individual_effective_period(row)
          return if row.effective_date < row.expiration_date

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            reason: 'Effective date must lie before before expiration date!',
            exception_class: ExcelDataServices::DataValidators::ValidationErrors::InsertableChecks
          )
        end

        def check_individual_hub(hub, info, row)
          return if hub

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            reason: "Hub \"#{info}\" (#{row.mot.capitalize}) not found!",
            exception_class: ExcelDataServices::DataValidators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
