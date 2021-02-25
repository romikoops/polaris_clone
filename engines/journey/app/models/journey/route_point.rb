# frozen_string_literal: true
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
#  id                  :uuid             not null, primary key
#  administrative_area :string           default("")
#  city                :string           default("")
#  coordinates         :geometry         not null, geometry, 0
#  country             :string
#  function            :string           not null
#  locode              :string
#  name                :string           not null
#  postal_code         :string           default("")
#  street              :string           default("")
#  street_number       :string           default("")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  geo_id              :string
#
