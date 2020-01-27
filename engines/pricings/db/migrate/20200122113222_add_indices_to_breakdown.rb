# frozen_string_literal: true

class AddIndicesToBreakdown < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :pricings_metadata, :charge_breakdown_id, algorithm: :concurrently
    add_index :pricings_metadata, :tenant_id, algorithm: :concurrently
    add_index :pricings_breakdowns, :metadatum_id, algorithm: :concurrently
    add_index :pricings_breakdowns, :margin_id, algorithm: :concurrently
    add_index :pricings_breakdowns, :charge_category_id, algorithm: :concurrently
    add_index :pricings_breakdowns, :charge_id, algorithm: :concurrently
  end
end
