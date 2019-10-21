# frozen_string_literal: true

class AddTransshipmentToNotes < ActiveRecord::Migration[5.2]
  def up
    add_column :notes, :transshipment, :boolean
    change_column_default :notes, :transshipment, false
  end

  def down
    remove_column :notes, :transshipment
  end
end
