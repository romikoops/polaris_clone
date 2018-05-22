class AddGdprToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :gdpr_status, :string
  end
end
