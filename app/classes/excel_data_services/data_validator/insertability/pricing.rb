# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Insertability
      class Pricing < Base
        private

        def check_single_row(row)
          user = get_user(row)
          check_customer_email(row, user)
          check_overlapping_effective_period(row, user)
        end

        def check_overlapping_effective_period(row, user)
          itinerary = Itinerary.find_by(name: row.itinerary_name, tenant: tenant)
          return if itinerary.nil?

          pricings = itinerary.pricings
                              .where(user: user, tenant_vehicle: find_tenant_vehicle(row))
                              .for_cargo_class(row.load_type)
                              .for_dates(row.effective_date, row.expiration_date)

          if items_have_differing_uuids?(pricings, row.uuid) # rubocop:disable Style/GuardClause
            raise ExcelDataServices::DataValidator::ValidationError::Insertability,
                  "Overlapping effective period. (UUID: #{row.uuid || 'empty'})"
          end
        end

        def get_user(row)
          User.find_by(tenant: tenant, email: row.customer_email)
        end

        def check_customer_email(row, user)
          unknown_customer = row.customer_email.present? && user.nil?
          if unknown_customer # rubocop:disable Style/GuardClause
            raise ExcelDataServices::DataValidator::ValidationError::Insertability,
                  "There exists no user with email: #{row.customer_email}."
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
