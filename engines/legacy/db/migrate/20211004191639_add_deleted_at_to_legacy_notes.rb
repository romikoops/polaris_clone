# frozen_string_literal: true

class AddDeletedAtToLegacyNotes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :notes, :deleted_at, :datetime
    add_index :notes, :deleted_at, algorithm: :concurrently
  end
end
