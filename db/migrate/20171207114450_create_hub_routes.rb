class CreateHubRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :hub_routes do |t|
        t.integer :starthub_id
        t.integer :endhub_id
        t.integer :route_id
      t.timestamps
    end
  end
end
