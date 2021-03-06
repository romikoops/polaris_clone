# frozen_string_literal: true

module Trucking
  class Location < ApplicationRecord
    UUID_V5_NAMESPACE = "404827a9-bc4d-4c97-b813-d925588215d6"

    validates :upsert_id,
      uniqueness: {
        message: "is a duplicate (all attributes match an existing record in the DB)"
      }
    validates :data, presence: true
    validates :query, presence: true

    belongs_to :country, class_name: "Legacy::Country"
    belongs_to :location, optional: true, class_name: "Locations::Location"
    has_many :truckings, class_name: "Trucking::Trucking"
    has_many :hubs, through: :truckings
    enum query: { postal_code: 0, location: 1, distance: 2 }
    enum identifier: {
      "postal_code" => "postal_code",
      "locode" => "locode",
      "city" => "city",
      "distance" => "distance",
      "postal_city" => "postal_city"
    }, _prefix: true

    acts_as_paranoid

    before_validation :generate_upsert_id

    def generate_upsert_id
      self.upsert_id = ::UUIDTools::UUID.sha1_create(::UUIDTools::UUID.parse(UUID_V5_NAMESPACE), [data.to_s, query.to_s, country_id.to_s].join)
    end
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
#  identifier   :enum
#  query        :integer
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  country_id   :bigint
#  location_id  :uuid
#  sandbox_id   :uuid
#  upsert_id    :uuid
#
# Indexes
#
#  index_trucking_locations_on_country_id   (country_id)
#  index_trucking_locations_on_data         (data)
#  index_trucking_locations_on_deleted_at   (deleted_at)
#  index_trucking_locations_on_location_id  (location_id)
#  index_trucking_locations_on_query        (query)
#  index_trucking_locations_on_sandbox_id   (sandbox_id)
#  index_trucking_locations_upsert          (upsert_id) UNIQUE WHERE (deleted_at IS NULL)
#
