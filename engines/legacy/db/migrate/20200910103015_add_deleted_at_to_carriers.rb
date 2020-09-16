class AddDeletedAtToCarriers < ActiveRecord::Migration[5.2]
  def change
    add_column :carriers, :deleted_at, :datetime
  end
end
