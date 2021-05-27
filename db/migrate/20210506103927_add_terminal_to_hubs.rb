# frozen_string_literal: true

class AddTerminalToHubs < ActiveRecord::Migration[5.2]
  def change
    add_column :hubs, :terminal, :string
    add_column :hubs, :terminal_code, :string
  end
end
