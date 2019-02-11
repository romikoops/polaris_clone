# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Insertability
      class Pricing < Base
        def check_data(row)
          check_overlapping_effective_period(row)
        end

        private

        def check_overlapping_effective_period(row)
          itinerary = Itinerary.find_by(name: row.itinerary_name, tenant: tenant)
          return if itinerary.nil?

          user = User.find_by(tenant: tenant, email: row.customer_email) if row.customer_email.present?
          row.cargo_classes.each do |cargo_class|
            pricings = itinerary.pricings
                                .where(user: user, tenant_vehicle: find_tenant_vehicle(row))
                                .for_cargo_class(cargo_class)
                                .for_dates(row.effective_date, row.expiration_date)

            if pricings_have_differing_uuids?(pricings, row.uuid)
              raise InsertabilityError, "Overlapping effective period. (UUID: #{row.uuid})"
            end
          end
        end

        def pricings_have_differing_uuids?(pricings, row_uuid)
          pricings.where.not(uuid: row_uuid).any?
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
