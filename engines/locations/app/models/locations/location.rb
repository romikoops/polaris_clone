# frozen_string_literal: true

module Locations
  class Location < ApplicationRecord
    validates :osm_id, uniqueness: true, if: :osm_data?
    validates :name, uniqueness: {scope: [:country_code]}

    acts_as_paranoid

    def self.contains(point:)
      where(arel_table[:bounds].st_contains(Arel::Nodes.build_quoted(point)))
    end

    def self.smallest_contains(point:)
      Locations::Location.contains(point: point).order(arel_table[:bounds].st_area)
    end

    def geojson
      RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(bounds))
    end

    def osm_data?
      osm_id.present?
    end
  end
end

# == Schema Information
#
# Table name: locations_locations
#
#  id           :uuid             not null, primary key
#  admin_level  :integer
#  bounds       :geometry         geometry, 4326
#  country_code :string
#  deleted_at   :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  osm_id       :bigint
#
# Indexes
#
#  index_locations_locations_on_bounds      (bounds) USING gist
#  index_locations_locations_on_deleted_at  (deleted_at)
#  index_locations_locations_on_name        (name)
#  index_locations_locations_on_osm_id      (osm_id)
#
