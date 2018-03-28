class EditStupidMistakes < ActiveRecord::Migration[5.1]
  def change
    remove_column :hub_truckings, :trucking_pricing, :integer
    add_column :hub_truckings, :trucking_pricing_id, :integer
  end
end
