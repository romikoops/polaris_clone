class AddDeletedAtToContainers < ActiveRecord::Migration[5.2]
  def change
    add_column :containers, :deleted_at, :datetime
  end
end
