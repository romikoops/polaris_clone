# frozen_string_literal: true

class AddIndexToDeletedAtOnGroupsMemberships < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :groups_groups, :deleted_at, algorithm: :concurrently
    add_index :groups_memberships, :deleted_at, algorithm: :concurrently
  end
end
