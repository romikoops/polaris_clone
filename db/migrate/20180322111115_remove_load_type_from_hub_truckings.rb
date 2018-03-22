class RemoveLoadTypeFromHubTruckings < ActiveRecord::Migration[5.1]
  def change
    remove_column :hub_truckings, :load_type, :string
    add_column :trucking_pricings, :truck_type, :string
  end
end
