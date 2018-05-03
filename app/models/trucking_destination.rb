class TruckingDestination < ApplicationRecord
   validates given_attribute_names.first.to_sym,
    uniqueness: {
      scope: given_attribute_names[1..-1],
      message: 'is a duplicate (all attributes match an existing record in the DB)'
    }

  def self.find_via_distance_to_hub(args = {})
    raise ArgumentError, "Must provide hub"       if args[:hub].nil?
    raise ArgumentError, "Must provide latitude"  if args[:latitude].nil?
    raise ArgumentError, "Must provide longitude" if args[:longitude].nil?

    find_by_sql("
      SELECT * FROM trucking_destinations
      WHERE distance = (
        SELECT ROUND(ST_Distance(
          ST_Point(#{args[:hub].longitude}, #{args[:hub].latitude})::geography,
          ST_Point(#{args[:longitude]}, #{args[:latitude]})::geography
        ) / 500)
      )
    ")
  end

  def self.a
    ActiveRecord::Base.connection.execute("
      SELECT ROUND(ST_Distance(
        ST_Point(11.100000, 57.000000)::geography,
        ST_Point(11.854048, 57.694253)::geography
      ) / 1000) as distance
    ")
  end

  def self.b
    find_by_sql("
      SELECT * FROM trucking_destinations
      WHERE distance = (
        SELECT ROUND(ST_Distance(
          ST_Point(11.100000, 57.000000)::geography,
          ST_Point(11.854048, 57.694253)::geography
        ) / 1000)
      )
    ")
  end

  def self.c
    TruckingPricing.find_by_sql("
      SELECT * FROM trucking_pricings
      JOIN  hub_truckings         ON hub_truckings.trucking_pricing_id     = trucking_pricings.id
      JOIN  trucking_destinations ON hub_truckings.trucking_destination_id = trucking_destinations.id
      JOIN  hubs                  ON hub_truckings.hub_id                  = hubs.id
      JOIN  locations             ON hubs.location_id                      = locations.id
      JOIN  tenants               ON hubs.tenant_id                        = tenants.id
      WHERE tenants.id = 2
      AND trucking_destinations.distance = (
        SELECT ROUND(ST_Distance(
          ST_Point(11.100000, 57.000000)::geography,
          ST_Point(11.854048, 57.694253)::geography
        ) / 1000)
      )
    ")
  end

  def self.d
    ActiveRecord::Base.connection.execute("
      SELECT locations.latitude, locations.longitude FROM trucking_pricings
      JOIN  hub_truckings         ON hub_truckings.trucking_pricing_id     = trucking_pricings.id
      JOIN  trucking_destinations ON hub_truckings.trucking_destination_id = trucking_destinations.id
      JOIN  hubs                  ON hub_truckings.hub_id                  = hubs.id
      JOIN  locations             ON hubs.location_id                      = locations.id
      JOIN  tenants               ON hubs.tenant_id                        = tenants.id
      WHERE tenants.id = 2
    ")
  end

  def self.e
    ActiveRecord::Base.connection.execute("
      SELECT trucking_destinations.distance FROM trucking_pricings
      JOIN  hub_truckings         ON hub_truckings.trucking_pricing_id     = trucking_pricings.id
      JOIN  trucking_destinations ON hub_truckings.trucking_destination_id = trucking_destinations.id
      JOIN  hubs                  ON hub_truckings.hub_id                  = hubs.id
      JOIN  locations             ON hubs.location_id                      = locations.id
      JOIN  tenants               ON hubs.tenant_id                        = tenants.id
      WHERE tenants.id = 2
    ")
  end
end




