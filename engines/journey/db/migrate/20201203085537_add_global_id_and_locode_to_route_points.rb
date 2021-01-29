class AddGlobalIdAndLocodeToRoutePoints < ActiveRecord::Migration[5.2]
  def change
    add_column :journey_route_points, :geo_id, :uuid
    add_column :journey_route_points, :locode, :string
  end
end
