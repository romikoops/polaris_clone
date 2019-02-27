# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module InsertableChecks
      class LocalCharges < ExcelDataServices::DataValidators::InsertableChecks::Base
        private

        def check_single_data(row)
          non_existent_hubs = check_hub_existence(row)
          check_overlapping_effective_period(row) unless non_existent_hubs
        end

        def check_overlapping_effective_period(row) # rubocop:disable Metrics/AbcSize
          hub = Hub.find_by(tenant: tenant, name: row.hub_name, hub_type: row.mot)
          counterpart_hub = Hub.find_by(tenant: tenant, name: row.counterpart_hub_name, hub_type: row.mot)
          local_charges = hub.local_charges
                             .where(tenant_vehicle: find_tenant_vehicle(row), counterpart_hub_id: counterpart_hub&.id)
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

        def check_hub_existence(row)
          hub_names = [row.hub_name, row.counterpart_hub_name].compact # counterpart hub can be nil

          non_existent_hubs = false
          hub_names.each do |hub_name|
            hub = Hub.find_by(tenant: tenant, name: hub_name)

            next if hub

            add_to_errors(
              type: :error,
              row_nr: row.nr,
              reason: "Hub with name \"#{hub_name}\" not found!",
              exception_class: ExcelDataServices::DataValidators::ValidationErrors::InsertableChecks
            )
            non_existent_hubs = true
          end

          non_existent_hubs
        end
      end
    end
  end
end
