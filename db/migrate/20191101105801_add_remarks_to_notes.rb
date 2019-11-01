# frozen_string_literal: true

class AddRemarksToNotes < ActiveRecord::Migration[5.2]
  def up
    add_column :notes, :remarks, :boolean
    change_column_default :notes, :remarks, false
  end

  def down
    remove_column :notes, :remarks
  end
end
