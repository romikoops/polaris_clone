class CreateRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :routes do |t|
      t.integer  :tenant_id
      t.integer  :origin_nexus_id
      t.integer  :destination_nexus_id
      t.string   :name
      t.timestamps
    end
  end
end
