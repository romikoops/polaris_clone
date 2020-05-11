# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class MaxDimensions < ExcelDataServices::Validators::InsertableChecks::Base
        VALID_LOAD_TYPES = (%w[lcl] + Container::CARGO_CLASSES).freeze

        private

        def check_single_data(row)
          check_load_type(row)
          check_locodes(row)
          check_mode_of_transport(row)
          check_aggregate(row)
        end

        def check_load_type(row)
          return if VALID_LOAD_TYPES.include?(row[:cargo_class])

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: 'The provided load type is invalid',
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def check_locodes(row)
          return if row[:origin_locode].blank? && row[:destination_locode].blank?

          %i[origin_locode destination_locode].each do |locode_key|
            next if Legacy::Hub.exists?(hub_code: row[locode_key], tenant_id: tenant.id)

            add_to_errors(
              type: :error,
              row_nr: row.nr,
              sheet_name: sheet_name,
              reason: "No hub exists with the LOCODE #{row[locode_key]}",
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end
        end

        def check_mode_of_transport(row)
          return if row[:origin_locode].blank? && row[:destination_locode].blank?

          return if Legacy::Itinerary::MODES_OF_TRANSPORT.include?(row[:mode_of_transport])

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: 'A valid mode of transport is required if assigning to a route',
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def check_aggregate(row)
          return if [true, false, nil].include?(row[:aggregate])

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: 'Aggregate can only be either True/False',
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
