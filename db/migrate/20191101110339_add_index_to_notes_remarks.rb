# frozen_string_literal: true

class AddIndexToNotesRemarks < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :notes, :remarks, algorithm: :concurrently
  end
end
