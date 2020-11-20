# frozen_string_literal: true

class CreateQuotationsTenders < ActiveRecord::Migration[5.2]
  def change
    create_table :quotations_tenders, id: :uuid do |t|
      t.references :quotation
      t.references :tenant_vehicle
      t.integer :origin_hub_id, index: true
      t.integer :destination_hub_id, index: true
      t.string :carrier_name
      t.string :name
      t.string :load_type
      t.monetize :amount, amount: {null: true, default: nil}, currency: {null: true, default: nil}

      t.timestamps
    end
  end
end
