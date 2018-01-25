class AddLocationToHub < ActiveRecord::Migration[5.1]
  def change
    add_column :hubs, :nexus_id, :integer
  end
end
