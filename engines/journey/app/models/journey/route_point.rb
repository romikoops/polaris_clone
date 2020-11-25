module Journey
  class RoutePoint < ApplicationRecord
    has_many :line_items

    validates :name, presence: true
    validates :function, presence: true
  end
end

# == Schema Information
#
# Table name: journey_route_points
#
#  id          :uuid             not null, primary key
#  coordinates :geometry         not null, geometry, 0
#  function    :string           not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
