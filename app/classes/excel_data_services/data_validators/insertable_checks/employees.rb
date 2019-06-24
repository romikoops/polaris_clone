# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module InsertableChecks
      class Employees < ExcelDataServices::DataValidators::InsertableChecks::Base
        private

        def check_single_data(row)
          check_customer_company(row)
          check_customer_password(row)
        end

        def check_customer_company(row)
          company = ::Tenants::Company.find_by(
            name: row[:company_name],
            tenant: ::Tenants::Tenant.find_by(legacy_id: tenant.id)
          )
          company_unknown = row[:company_name].present? && company.nil?

          if company_unknown # rubocop:disable Style/GuardClause
            add_to_errors(
              type: :error,
              row_nr: row.nr,
              reason: "There exists no company with name: #{row[:company_name]}.",
              exception_class: ExcelDataServices::DataValidators::ValidationErrors::InsertableChecks
            )
          end
        end

        def check_customer_password(row)
          if row[:password]&.length&.< 8 # rubocop:disable Style/GuardClause
            add_to_errors(
              type: :error,
              row_nr: row.nr,
              reason: 'The minimum password length is 8 characters.',
              exception_class: ExcelDataServices::DataValidators::ValidationErrors::InsertableChecks
            )
          end
        end
      end
    end
  end
end
