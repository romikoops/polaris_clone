# frozen_string_literal: true

class AddIndexToFeesUpsertId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_lock_timeout(1000)
  set_statement_timeout(15_000)

  def change
    add_index :pricings_fees, :upsert_id, algorithm: :concurrently
  end
end
