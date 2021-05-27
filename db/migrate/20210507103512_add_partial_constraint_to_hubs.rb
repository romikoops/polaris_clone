# frozen_string_literal: true

class AddPartialConstraintToHubs < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_lock_timeout(1000)
  set_statement_timeout(3000)

  def change
    add_index :hubs, %i[
      nexus_id
      hub_type
      name
      organization_id
    ],
      unique: true,
      where: "terminal is null",
      algorithm: :concurrently,
      name: "hub_upsert"
  end
end
