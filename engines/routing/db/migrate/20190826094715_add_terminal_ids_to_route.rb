# frozen_string_literal: true
class AddTerminalIdsToRoute < ActiveRecord::Migration[5.2]
  def change
    add_column :routing_routes, :origin_terminal_id, :uuid
    add_column :routing_routes, :destination_terminal_id, :uuid
    add_column :routing_terminals, :mode_of_transport, :integer
    change_column_default :routing_terminals, :mode_of_transport, 0
  end
end
