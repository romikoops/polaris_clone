# frozen_string_literal: true
class AddParanoiaIndexToLegacyChargeModels < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :charge_breakdowns, :deleted_at, algorithm: :concurrently
    add_index :charges, :deleted_at, algorithm: :concurrently
  end
end
