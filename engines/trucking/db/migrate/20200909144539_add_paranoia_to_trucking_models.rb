class AddParanoiaToTruckingModels < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_truckings, :deleted_at, :datetime
  end
end
