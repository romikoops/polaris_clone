class TruckingDestination < ApplicationRecord
   validates given_attribute_names.first.to_sym,
    uniqueness: {
      scope: given_attribute_names[1..-1],
      message: 'is a duplicate (all attributes match an existing record in the DB)'
    }

    def self.test
      sql = "SELECT * FROM trucking_pricings
        JOIN  hub_truckings         ON hub_truckings.trucking_pricing_id     = trucking_pricings.id
        JOIN  trucking_destinations ON hub_truckings.trucking_destination_id = trucking_destinations.id
        JOIN  hubs                  ON hub_truckings.hub_id                  = hubs.id
        JOIN  locations             ON hubs.location_id                      = locations.id
        JOIN  tenants                ON hubs.tenant_id                        = tenants.id
        WHERE tenants.id = 61
        AND hub_truckings.load_type = 'lcl'
        AND (
          (
            (trucking_destinations.zipcode IS NOT NULL)
            AND (trucking_destinations.zipcode = '15000')
          ) OR (
            (trucking_destinations.city_name IS NOT NULL)
            AND (trucking_destinations.city_name = '')
          )
        )
        "
        # 
      TruckingPricing.find_by_sql(sql)
      # ActiveRecord::Base.connection.execute(sql)
    end
end
