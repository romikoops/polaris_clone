# frozen_string_literal: true

class RemoveDefaultUpsertIndexFromPricingsFee < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_lock_timeout(2000)
  set_statement_timeout(5000)

  def change
    remove_index :pricings_fees, :upsert_id
  end
end
