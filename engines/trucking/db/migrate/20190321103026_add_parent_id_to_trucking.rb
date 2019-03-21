class AddParentIdToTrucking < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_truckings, :parent_id, :uuid
  end
end
