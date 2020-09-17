# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class Employees < ExcelDataServices::Validators::InsertableChecks::Base
        private

        def check_single_data(row)
          check_customer_company(row)
          check_customer_password(row)
        end

        def check_customer_company(row)
          company = ::Companies::Company.find_by(
            name: row[:company_name],
            organization: organization
          )
          company_unknown = row[:company_name].present? && company.nil?

          if company_unknown
            add_to_errors(
              type: :error,
              row_nr: row.nr,
              sheet_name: sheet_name,
              reason: "There exists no company with name: #{row[:company_name]}.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end
        end

        def check_customer_password(row)
          if row[:password]&.length&.< 8
            add_to_errors(
              type: :error,
              row_nr: row.nr,
              sheet_name: sheet_name,
              reason: 'The minimum password length is 8 characters.',
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end
        end
      end
    end
  end
end
