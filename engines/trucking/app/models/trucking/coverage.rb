# frozen_string_literal: true

module Trucking
  class Coverage < ApplicationRecord
    belongs_to :hub, class_name: 'Legacy::Hub'
    has_many :truckings, through: :hub

    before_validation :generate_bounds


    def geojson
      RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(bounds))
    end
    
    private

    def generate_bounds
      self.bounds = Locations::Location
                    .where(
                      id: Location.joins(:truckings).where(trucking_truckings: { hub_id: hub.id }).select(:location_id)
                    )
                    .pluck('ST_Collect(bounds)').first
    end
  end
end

# == Schema Information
#
# Table name: trucking_coverages
#
#  id         :uuid             not null, primary key
#  hub_id     :integer
#  bounds     :geometry({:srid= geometry, 0
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
