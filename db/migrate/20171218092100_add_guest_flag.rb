class AddGuestFlag < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :anonymous, :boolean
  end
end
