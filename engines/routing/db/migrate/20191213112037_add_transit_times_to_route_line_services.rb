# frozen_string_literal: true

class AddTransitTimesToRouteLineServices < ActiveRecord::Migration[5.2]
  def change
    add_column :routing_route_line_services, :transit_time, :integer
  end
end
