# frozen_string_literal: true

class AddIndexToPricingsBreakdown < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :pricings_breakdowns, %i[source_type source_id], algorithm: :concurrently
  end
end
