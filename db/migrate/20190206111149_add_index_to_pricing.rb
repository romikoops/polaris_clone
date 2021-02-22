# frozen_string_literal: true
class AddIndexToPricing < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :pricings, :uuid, unique: true, algorithm: :concurrently
  end
end
