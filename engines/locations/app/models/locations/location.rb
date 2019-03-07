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
#  bounds       :geometry({:srid= geometry, 0
#  osm_id       :bigint(8)
#  name         :string
#  admin_level  :integer
#  country_code :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
