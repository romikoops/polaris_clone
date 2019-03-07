class AddDeletedAtToUsers < ActiveRecord::Migration[5.2]
  def change
      add_column :users, :deleted_at, :datetime
      add_column :user_addresses, :deleted_at, :datetime
  end
end
