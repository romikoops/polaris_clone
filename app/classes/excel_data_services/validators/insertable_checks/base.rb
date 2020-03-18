# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class Base < ExcelDataServices::Validators::Base
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

        def check_group(row)
          if row.group_id.present?
            group_by_id = Tenants::Group.find_by(tenant: @tenants_tenant, id: row.group_id)

            check_group_by_id(row, group_by_id)
          end

          if row.group_name.present?
            group_by_name = Tenants::Group.find_by(tenant: @tenants_tenant, name: row.group_name)

            check_group_by_name(row, group_by_name)
          end

          check_groups_are_the_same(row, group_by_id, group_by_name) if [group_by_id, group_by_name].all?
        end

        def check_group_by_id(row, group_by_id)
          return if group_by_id.present?

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "The Group with ID '#{row.group_id}' does not exist!",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def check_group_by_name(row, group_by_name)
          return if group_by_name.present?

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "The Group with name '#{row.group_name}' does not exist!",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def check_groups_are_the_same(row, group_by_id, group_by_name)
          return if group_by_id == group_by_name

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "The Group with ID '#{row.group_id}' is not the same as the group with name '#{row.group_name}'!",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def check_correct_individual_effective_period(row)
          return if row.effective_date < row.expiration_date

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: 'Effective date must lie before before expiration date!',
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def check_hub_existence(hub_with_info, row)
          return if hub_with_info[:hub]

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "Hub \"#{hub_with_info[:found_by_info]}\" (#{row.mot.capitalize}) not found!",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
