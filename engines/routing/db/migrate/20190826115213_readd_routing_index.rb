# frozen_string_literal: true
class ReaddRoutingIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :routing_routes, %i[
      origin_id destination_id origin_terminal_id destination_terminal_id mode_of_transport
    ], unique: true, name: "routing_routes_index", algorithm: :concurrently
  end
end
