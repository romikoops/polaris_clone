class AddDeletedAtToCargoItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cargo_items, :deleted_at, :datetime
  end
end
