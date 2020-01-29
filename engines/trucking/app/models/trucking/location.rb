# frozen_string_literal: true

module Trucking
  class Location < ApplicationRecord
    validates :zipcode,
              uniqueness: {
                scope: %i(country_code city_name distance location_id sandbox_id),
                message: 'is a duplicate (all attributes match an existing record in the DB)'
              }

    belongs_to :location, optional: true, class_name: 'Locations::Location'
    has_many :truckings, class_name: 'Trucking::Trucking'
    has_many :rates, class_name: 'Trucking::Rate', through: :truckings
    has_many :hubs, through: :hub_truckings
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
  end
end

# == Schema Information
#
# Table name: trucking_locations
#
#  id           :uuid             not null, primary key
#  city_name    :string
#  country_code :string
#  distance     :integer
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  location_id  :uuid
#  sandbox_id   :uuid
#
# Indexes
#
#  index_trucking_locations_on_city_name     (city_name)
#  index_trucking_locations_on_country_code  (country_code)
#  index_trucking_locations_on_distance      (distance)
#  index_trucking_locations_on_location_id   (location_id)
#  index_trucking_locations_on_sandbox_id    (sandbox_id)
#  index_trucking_locations_on_zipcode       (zipcode)
#
