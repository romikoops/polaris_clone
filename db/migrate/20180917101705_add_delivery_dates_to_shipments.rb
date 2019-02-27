# frozen_string_literal: true

class AddDeliveryDatesToShipments < ActiveRecord::Migration[5.2]
  def change
    add_column :shipments, :planned_delivery_date, :datetime
    add_column :shipments, :planned_destination_collection_date, :datetime
  end
end
