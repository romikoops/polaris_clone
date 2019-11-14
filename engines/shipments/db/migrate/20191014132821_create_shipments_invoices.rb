# frozen_string_literal: true

class CreateShipmentsInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :shipments_invoices, id: :uuid do |t|
      t.references :sandbox, foreign_key: { to_table: :tenants_sandboxes }, type: :uuid, index: true
      t.references :shipment, type: :uuid, index: true, null: false

      t.bigint :invoice_number
      t.monetize :amount, currency: { present: false }
      t.timestamps
    end
  end
end
