module Locations
  class Location < ApplicationRecord
    has_many :names
    validates :bounds, uniqueness: {
     message: ->(record, _) { "is a duplicate for the names: #{record.names.to_s.tr('"', "'")}" }
    }
  end
end

# == Schema Information
#
# Table name: locations_locations
#
#  id          :uuid             not null, primary key
#  bounds      :geometry({:srid= geometry, 0
#  osm_id      :integer
#  name        :string
#  admin_level :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
