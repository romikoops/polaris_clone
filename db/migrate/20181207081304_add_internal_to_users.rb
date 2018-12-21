# frozen_string_literal: true

class AddInternalToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :internal, :boolean
    change_column_default :users, :internal, false
  end
end
