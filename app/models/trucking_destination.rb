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

    where("
      distance = (
        SELECT ROUND(ST_Distance(
          ST_Point(:hub_lng, :hub_lat)::geography,
          ST_Point(:lng, :lat)::geography
        ) / 500)
      )
    ",
      hub_lng: args[:hub].longitude,
      hub_lat: args[:hub].latitude,
      lng:     args[:longitude],
      lat:     args[:latitude]
    )
  end
end
