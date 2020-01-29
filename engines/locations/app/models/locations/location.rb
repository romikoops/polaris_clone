# frozen_string_literal: true

module Locations
  class Location < ApplicationRecord
    validates :osm_id, uniqueness: true

    def self.contains(lat:, lon:)
      where(arel_table[:bounds].st_contains("POINT(#{lon} #{lat})"))
    end

    def self.smallest_contains(lat:, lon:)
      where(arel_table[:bounds].st_contains("POINT(#{lon} #{lat})")).order(arel_table[:bounds].st_area)
    end

    def geojson
      RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(bounds))
    end
  end
end

# == Schema Information
#
# Table name: locations_locations
#
#  id           :uuid             not null, primary key
#  admin_level  :integer
#  bounds       :geometry({:srid= geometry, 0
#  country_code :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  osm_id       :bigint
#
# Indexes
#
#  index_locations_locations_on_bounds  (bounds) USING gist
#  index_locations_locations_on_name    (name)
#  index_locations_locations_on_osm_id  (osm_id)
#
