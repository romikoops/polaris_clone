# frozen_string_literal: true

class AddIndexToPricingsAndFeesDeletedAt < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_statement_timeout(10_000)

  def change
    add_index :pricings_pricings, :deleted_at, algorithm: :concurrently
  end
end
