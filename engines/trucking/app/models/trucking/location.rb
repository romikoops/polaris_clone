# frozen_string_literal: true

module Trucking
  class Location < ApplicationRecord
    validates :data,
      uniqueness: {
        scope: %i[query location_id],
        message: "is a duplicate (all attributes match an existing record in the DB)"
      }

    belongs_to :country, optional: true, class_name: "Legacy::Country"
    belongs_to :location, optional: true, class_name: "Locations::Location"
    has_many :truckings, class_name: "Trucking::Trucking"
    has_many :hubs, through: :truckings
    enum query: {postal_code: 0, location: 1, distance: 2}

    acts_as_paranoid
  end
end

# == Schema Information
#
# Table name: trucking_locations
#
#  id           :uuid             not null, primary key
#  city_name    :string
#  country_code :string
#  data         :string
#  deleted_at   :datetime
#  distance     :integer
#  query        :integer
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  country_id   :bigint
#  location_id  :uuid
#  sandbox_id   :uuid
#
# Indexes
#
#  index_trucking_locations_on_city_name     (city_name)
#  index_trucking_locations_on_country_code  (country_code)
#  index_trucking_locations_on_country_id    (country_id)
#  index_trucking_locations_on_data          (data)
#  index_trucking_locations_on_deleted_at    (deleted_at)
#  index_trucking_locations_on_distance      (distance)
#  index_trucking_locations_on_location_id   (location_id)
#  index_trucking_locations_on_query         (query)
#  index_trucking_locations_on_sandbox_id    (sandbox_id)
#  index_trucking_locations_on_zipcode       (zipcode)
#  trucking_locations_upsert                 (data,query,country_id,deleted_at) UNIQUE
#
