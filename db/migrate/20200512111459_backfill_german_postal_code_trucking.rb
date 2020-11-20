# frozen_string_literal: true

class BackfillGermanPostalCodeTrucking < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      hub_ids = Legacy::Hub.joins(address: :country)
        .where(countries: {code: "DE"})
        .select(:id)
      Trucking::TypeAvailability.joins(:hub_availabilities)
        .where(
          trucking_hub_availabilities: {
            hub_id: hub_ids
          },
          query_method: 2
        ).update_all(query_method: 3)
      execute("
        UPDATE trucking_locations
        SET location_id = locations_locations.id
        FROM locations_locations
        WHERE trucking_locations.country_code = 'DE'
        AND trucking_locations.zipcode IS NOT NULL
        AND locations_locations.name = trucking_locations.zipcode
        AND locations_locations.country_code = 'de'
        ")
    end
  end
end
