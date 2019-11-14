# frozen_string_literal: true

class CreateShipmentsLineItems < ActiveRecord::Migration[5.2]
  def change
    create_table :shipments_line_items, id: :uuid do |t|
      t.monetize :amount, currency: { default: nil }
      t.string :fee_code
      t.references :cargo, type: :uuid
      t.references :invoice, type: :uuid, index: true, null: false

      t.timestamps
    end
  end
end
