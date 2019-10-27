# frozen_string_literal: true

class AddFreeOutBooleanToHubs < ActiveRecord::Migration[5.2]
  def up
    add_column :hubs, :free_out, :boolean
    change_column_default :hubs, :free_out, false
  end

  def down
    remove_column :hubs, :free_out
  end
end
