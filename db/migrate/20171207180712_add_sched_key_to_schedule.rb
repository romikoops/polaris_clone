class AddSchedKeyToSchedule < ActiveRecord::Migration[5.1]
  def change
    add_column :schedules, :hub_route_key, :string
  end
end
