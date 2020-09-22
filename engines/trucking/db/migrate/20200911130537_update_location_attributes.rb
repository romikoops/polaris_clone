class UpdateLocationAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_locations, :data, :string
    add_column :trucking_locations, :query, :integer
  end
end
