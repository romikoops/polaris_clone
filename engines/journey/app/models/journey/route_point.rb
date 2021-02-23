# frozen_string_literal: true
module Journey
  class RoutePoint < ApplicationRecord
    has_many :line_items

    validates :name, presence: true
    validates :function, presence: true
    validates :geo_id, uniqueness: true
  end
end

# == Schema Information
#
# Table name: journey_route_points
#
#  id          :uuid             not null, primary key
#  coordinates :geometry         not null, geometry, 0
#  function    :string           not null
#  locode      :string
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  geo_id      :string
#
# Indexes
#
#  index_journey_route_points_on_geo_id  (geo_id) UNIQUE
#
