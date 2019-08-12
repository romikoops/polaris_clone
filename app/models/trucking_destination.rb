# frozen_string_literal: true

class TruckingDestination < ApplicationRecord
  validates :zipcode,
            uniqueness: {
              scope: %i(country_code city_name distance location_id sandbox_id),
              message: 'is a duplicate (all attributes match an existing record in the DB)'
            }

  belongs_to :location, optional: true
  has_many :hub_truckings
  has_many :trucking_pricings, through: :hub_truckings
  has_many :hubs, through: :hub_truckings

  def self.find_via_distance_to_hub(args = {})
    raise ArgumentError, 'Must provide hub'       if args[:hub].nil?
    raise ArgumentError, 'Must provide latitude'  if args[:latitude].nil?
    raise ArgumentError, 'Must provide longitude' if args[:longitude].nil?

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
          lng: args[:longitude],
          lat: args[:latitude])
  end
end

# == Schema Information
#
# Table name: trucking_destinations
#
#  id           :bigint(8)        not null, primary key
#  zipcode      :string
#  country_code :string
#  city_name    :string
#  distance     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  location_id  :integer
#  sandbox_id   :uuid
#
