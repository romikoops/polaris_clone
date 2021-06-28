# frozen_string_literal: true

class AddIndexToPricingsUpsertId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  set_lock_timeout(1000)
  set_statement_timeout(10_000)

  def change
    add_index :pricings_pricings, :upsert_id, algorithm: :concurrently
  end
end
