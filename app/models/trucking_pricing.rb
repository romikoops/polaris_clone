class TruckingPricing < ApplicationRecord
  has_many :shipments
  belongs_to :courier
  has_many :hub_truckings, dependent: :destroy
  has_many :hubs, through: :hub_truckings
  extend MongoTools
  # Validations

  # Class methods
  def self.update_data
    TruckingPricing.all.each do |tp|
      tp.modifier = 'kg'
      tp.save!
    end
  end

  def self.find_by_filter(args = {})
    raise ArgumentError, "Must provide load_type"                        if args[:load_type].nil?
    raise ArgumentError, "Must provide a valid filter besides load_type" if args.keys.size < 2
    latitude  = args[:latitude]  || args[:location].try(:latitude)  || 0
    longitude = args[:longitude] || args[:location].try(:longitude) || 0
    zipcode   = args[:zipcode]   || args[:location].try(:get_zip_code)
    city_name = args[:city_name] || args[:location].try(:city)

    find_by_sql("
      SELECT * FROM trucking_pricings
      JOIN  hub_truckings         ON hub_truckings.trucking_pricing_id     = trucking_pricings.id
      JOIN  trucking_destinations ON hub_truckings.trucking_destination_id = trucking_destinations.id
      JOIN  hubs                  ON hub_truckings.hub_id                  = hubs.id
      JOIN  locations             ON hubs.location_id                      = locations.id
      JOIN  tenants               ON hubs.tenant_id                        = tenants.id
      WHERE tenants.id = 2
      AND trucking_pricings.load_type = '#{args[:load_type]}'
      AND (
        (
          (trucking_destinations.zipcode IS NOT NULL)
          AND (trucking_destinations.zipcode = '#{zipcode}')
        ) OR (
          (trucking_destinations.city_name IS NOT NULL)
          AND (trucking_destinations.city_name = '#{city_name}')
        ) OR (
          (trucking_destinations.distance IS NOT NULL)
          AND (
            trucking_destinations.distance = (
              SELECT ROUND(ST_Distance(
                ST_Point(locations.longitude, locations.latitude)::geography,
                ST_Point(#{latitude}, #{longitude})::geography
              ) / 1000)
            )
          )
        )
      )
    ")

  end
end
