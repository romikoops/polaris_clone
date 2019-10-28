# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module InsertableChecks
      class LocalCharges < ExcelDataServices::DataValidators::InsertableChecks::Base
        private

        def check_single_data(row)
          check_correct_individual_effective_period(row)

          origin_hub, origin_hub_info = find_hub_by_name_or_locode_with_info(
            raw_name: row.hub,
            mot: row.mot,
            locode: row.hub_locode
          )
          check_individual_hub(origin_hub, origin_hub_info, row)

          return unless origin_hub

          if row.counterpart_hub || row.counterpart_hub_locode
            counterpart_hub, counterpart_hub_info = find_hub_by_name_or_locode_with_info(
              raw_name: row.counterpart_hub,
              mot: row.mot,
              locode: row.counterpart_hub_locode
            )
            check_individual_hub(counterpart_hub, counterpart_hub_info, row)
          end

          check_overlapping_effective_periods(row, origin_hub, counterpart_hub)
        end

        def check_overlapping_effective_periods(row, origin_hub, counterpart_hub)
          local_charges = origin_hub.local_charges
                                    .where(tenant_vehicle: find_tenant_vehicle(row),
                                           counterpart_hub_id: counterpart_hub&.id)
                                    .for_mode_of_transport(row.mot)
                                    .for_load_type(row.load_type) # in `Pricing` this is called cargo_class!!!
                                    .for_dates(row.effective_date, row.expiration_date)

          local_charges.each do |old_local_charge|
            overlap_checker = DateOverlapChecker.new(old_local_charge, row)
            checker_that_hits = overlap_checker.perform
            next if checker_that_hits == 'no_overlap'

            add_to_errors(
              type: :warning,
              row_nr: row.nr,
              reason: "Overlapping effective period.\n (#{checker_that_hits.humanize}: " \
                      "[#{overlap_checker.old_effective_period}] <-> [#{overlap_checker.new_effective_period}]).",
              exception_class: ExcelDataServices::DataValidators::ValidationErrors::InsertableChecks
            )
          end
        end

        def find_tenant_vehicle(row)
          carrier = Carrier.find_by(name: row.carrier) unless row.carrier.blank?

          TenantVehicle.find_by(
            tenant: tenant,
            name: row.service_level,
            mode_of_transport: row.mot,
            carrier: carrier
          )
        end
      end
    end
  end
end
