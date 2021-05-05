# frozen_string_literal: true

class UpdateLocationConstraints < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_statement_timeout(3000)

  def change
    add_index :trucking_locations, :upsert_id,
      unique: true,
      where: "deleted_at is null",
      algorithm: :concurrently,
      name: "index_trucking_locations_upsert"
  end
end
