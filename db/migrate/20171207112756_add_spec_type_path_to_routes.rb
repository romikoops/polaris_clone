class AddSpecTypePathToRoutes < ActiveRecord::Migration[5.1]
  def change
    add_column :schedules, :hub_route_id, :integer
    add_column :schedules, :vehicle_type_id, :integer
    remove_column :schedules, :starthub_id, :integer
    remove_column :schedules, :endhub_id, :integer
  end
end
