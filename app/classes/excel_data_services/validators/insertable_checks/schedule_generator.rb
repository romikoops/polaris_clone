# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class ScheduleGenerator < ExcelDataServices::Validators::InsertableChecks::Base
        private

        def check_single_data(row)
          check_carrier_exists(row)
          check_itinerary_exists(row)
        end

        def check_carrier_exists(row)
          carrier = row.carrier
          return if carrier.nil?

          return if Legacy::Carrier.find_by(code: carrier.downcase).present?

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "There exists no carrier called '#{carrier}'.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def check_itinerary_exists(row)
          itinerary_name = row.itinerary_name
          return if Legacy::Itinerary.where("name ILIKE ?", itinerary_name)
            .exists?(organization: organization, mode_of_transport: row.mode_of_transport)

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "There exists no itinerary called '#{itinerary_name}'.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
