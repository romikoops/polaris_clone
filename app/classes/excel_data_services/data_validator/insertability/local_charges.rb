# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Insertability
      class LocalCharges < Base
        private

        def check_single_row(row)
          check_overlapping_effective_period(row)
        end

        def check_overlapping_effective_period(row)
          local_charges = Hub.find(row.hub_id).local_charges
                                .where(tenant_vehicle: find_tenant_vehicle(row), counterpart_hub_id: row.counterpart_hub_id)
                                .for_mode_of_transport(row.mot)
                                .for_load_type(row.load_type) # in `Pricing` this is called cargo_class!!!
                                .for_dates(row.effective_date, row.expiration_date)

          if items_have_differing_uuids?(local_charges, row.uuid)
            raise InsertabilityError,
                  "Overlapping effective period. (UUID: #{row.uuid})"
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
