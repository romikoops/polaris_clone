# frozen_string_literal: true

class AddConstraintsToHubs < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_lock_timeout(1000)
  set_statement_timeout(3000)
  def change
    add_index :hubs, %i[
      nexus_id
      name
      hub_type
      organization_id
      terminal
    ],
      unique: true,
      algorithm: :concurrently,
      name: "hub_terminal_upsert"
  end
end
