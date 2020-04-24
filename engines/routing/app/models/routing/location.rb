# frozen_string_literal: true

module Routing
  class Location < ApplicationRecord
    has_many :terminals, class_name: 'Routing::Terminal'
    has_many :inbound_routes, class_name: 'Routing::Route', foreign_key: :destination_id
    has_many :outbound_routes, class_name: 'Routing::Route', foreign_key: :origin_id
  end
end

# == Schema Information
#
# Table name: routing_locations
#
#  id           :uuid             not null, primary key
#  bounds       :geometry         geometry, 0
#  center       :geometry         geometry, 0
#  country_code :string
#  locode       :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_routing_locations_on_bounds  (bounds) USING gist
#  index_routing_locations_on_center  (center)
#  index_routing_locations_on_locode  (locode)
#
