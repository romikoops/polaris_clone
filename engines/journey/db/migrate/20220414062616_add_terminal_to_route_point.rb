# frozen_string_literal: true

class AddTerminalToRoutePoint < ActiveRecord::Migration[5.2]
  def change
    add_column :journey_route_points, :terminal, :string
  end
end
