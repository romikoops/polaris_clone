class RemoveCargoGroupIdFromCargoItems < ActiveRecord::Migration[5.1]
  def change
    remove_column :cargo_items, :cargo_group_id, :integer
  end
end
