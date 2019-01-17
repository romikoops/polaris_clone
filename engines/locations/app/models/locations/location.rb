# frozen_string_literal: true

module Locations
  class Location < ApplicationRecord
    has_many :names
    validates :osm_id, uniqueness: {
      scope: %i(
        bounds
        admin_level
        name
      ),
      message: ->(record, _) { "is a duplicate for the names: #{[record.name, record.admin_level].join(', ')}" }
    }

    def self.contains(lat:, lon:)
      where(arel_table[:bounds].st_contains("POINT(#{lon} #{lat})"))
    end
  end
end

# == Schema Information
#
# Table name: locations_locations
#
#  id          :uuid             not null, primary key
#  bounds      :geometry({:srid= geometry, 0
#  osm_id      :bigint(8)
#  name        :string
#  admin_level :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
