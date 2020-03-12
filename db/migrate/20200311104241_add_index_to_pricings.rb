# frozen_string_literal: true

class AddIndexToPricings < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :pricings_pricings, :group_id, algorithm: :concurrently
    add_index :pricings_fees, :pricing_id, algorithm: :concurrently
    add_index :pricings_margins, :margin_type, algorithm: :concurrently
    add_index :pricings_details, :charge_category_id, algorithm: :concurrently
  end
end
