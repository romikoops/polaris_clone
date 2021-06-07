# frozen_string_literal: true

class AddConstraintToNexus < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :nexuses, %i[
      locode
      organization_id
    ],
      unique: true,
      algorithm: :concurrently,
      name: "nexus_upsert"
  end
end
