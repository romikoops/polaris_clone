class AddTransitTimeToRouteSections < ActiveRecord::Migration[5.2]
  def change
    add_column :journey_route_sections, :transit_time, :integer, null: false
  end
end
