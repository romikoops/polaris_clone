# frozen_string_literal: true

class CreateShipmentsCargos < ActiveRecord::Migration[5.2]
  def change
    create_table :shipments_cargos, id: :uuid do |t|
      t.references :sandbox, foreign_key: {to_table: :tenants_sandboxes}, type: :uuid, index: true
      t.references :shipment, type: :uuid, index: true
      t.references :tenant, foreign_key: {to_table: :tenants_tenants}, type: :uuid, index: true
      t.monetize :total_goods_value, currency: {default: nil}

      t.timestamps
    end
  end
end
