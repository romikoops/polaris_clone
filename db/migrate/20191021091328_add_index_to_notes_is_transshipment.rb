# frozen_string_literal: true

class AddIndexToNotesIsTransshipment < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :notes, :transshipment, algorithm: :concurrently
  end
end
