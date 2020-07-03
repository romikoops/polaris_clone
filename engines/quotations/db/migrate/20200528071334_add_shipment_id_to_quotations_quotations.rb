# frozen_string_literal: true

class AddShipmentIdToQuotationsQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_quotations, :shipment_id, :integer,
               index: true, foreign_key: { to_table: 'shipments' }
  end
end
