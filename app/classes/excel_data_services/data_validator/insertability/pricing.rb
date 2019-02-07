# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Insertability
      class Pricing < Base
        def perform
          super do |row|
            overlapping_effective_period(row)
          end
        end

        private

        def overlapping_effective_period(row)
          return if row.itinerary.nil?

          row.cargo_classes.each do |cargo_class|
            pricings = row.itinerary.pricings
                          .where(user: row.user, tenant_vehicle: row.tenant_vehicle)
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
      end
    end
  end
end
