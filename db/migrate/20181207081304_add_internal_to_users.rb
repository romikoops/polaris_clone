# frozen_string_literal: true

class AddInternalToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :internal, :boolean
    change_column_default :users, :internal, false
  end
end
