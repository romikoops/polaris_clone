# frozen_string_literal: true
class CorrectGeoIdType < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :journey_route_points, :geo_id }
    add_column :journey_route_points, :geo_id, :string
  end
end
