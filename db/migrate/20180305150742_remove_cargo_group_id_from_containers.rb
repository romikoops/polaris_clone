class RemoveCargoGroupIdFromContainers < ActiveRecord::Migration[5.1]
  def change
    remove_column :containers, :cargo_group_id, :integer
  end
end
