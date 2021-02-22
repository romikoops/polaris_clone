# frozen_string_literal: true
class AddBillingEnumToShipmentRequest < ActiveRecord::Migration[5.2]
  def up
    add_column :shipments_shipment_requests, :billing, :integer, index: true
    change_column_default :shipments_shipment_requests, :billing, 0
  end

  def down
    remove_column :shipments_shipment_requests, :billing
  end
end
