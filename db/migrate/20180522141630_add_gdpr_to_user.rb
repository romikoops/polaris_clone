class AddGdprToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :optin_status, :jsonb, default: {}
  end
end
