# frozen_string_literal: true

class AddUpsertIdToPricingsAndFees < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings_pricings, :upsert_id, :uuid
    add_column :pricings_fees, :upsert_id, :uuid
  end
end
