# frozen_string_literal: true

class AddOwnerToApplication < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :oauth_applications, :owner_id, :uuid, null: true
    add_column :oauth_applications, :owner_type, :string, null: true
    add_index :oauth_applications, %i[owner_id owner_type], algorithm: :concurrently
  end
end
