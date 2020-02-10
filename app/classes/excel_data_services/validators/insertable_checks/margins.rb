# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class Margins < ExcelDataServices::Validators::InsertableChecks::Base
        private

        def check_single_data(row)
          check_correct_individual_effective_period(row)
          itinerary = check_itinerary(row)
          check_overlapping_effective_periods(row, itinerary)
        end

        def check_itinerary(row)
          itinerary = Itinerary.find_by(
            name: row.itinerary_name,
            tenant: tenant,
            mode_of_transport: row.mode_of_transport
          )
          return itinerary if itinerary.present?

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "No Itinerary can be found with the name #{row.itinerary_name} (#{row.mode_of_transport}).",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )

          nil
        end

        def check_overlapping_effective_periods(row, itinerary)
          return if itinerary.nil?

          margins = Pricings::Margin
                    .where(
                      itinerary: itinerary,
                      tenant_vehicle: find_tenant_vehicle(row),
                      applicable: options[:applicable],
                      margin_type: row.margin_type
                    )
                    .for_cargo_classes([row.load_type])
                    .for_dates(row.effective_date, row.expiration_date)

          margins.each do |old_margin|
            overlap_checker = DateOverlapChecker.new(old_margin, row)
            checker_that_hits = overlap_checker.perform
            next if checker_that_hits == 'no_overlap'

            add_to_errors(
              type: :warning,
              row_nr: row.nr,
              sheet_name: sheet_name,
              reason: "There exist margins (in the system or this file) with an overlapping effective period.\n" \
                      "(#{checker_that_hits.humanize}: " \
                      "[#{overlap_checker.old_effective_period}] <-> [#{overlap_checker.new_effective_period}]).",
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end
        end

        def find_tenant_vehicle(row)
          carrier = Carrier.find_by(name: row.carrier) if row.carrier.present?

          tenant_vehicle = TenantVehicle.find_by(
            tenant: tenant,
            name: row.service_level,
            mode_of_transport: row.mot,
            carrier: carrier
          )

          return tenant_vehicle if tenant_vehicle.present?

          add_to_errors(
            type: :warning,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "There is specified service level does not exist in the database.\n" \
                    "#{row.service_level} - #{row.carrier}.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )

          nil
        end
      end
    end
  end
end
