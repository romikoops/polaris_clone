# frozen_string_literal: true

class AddOriginalShipmentIdToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :original_shipment_id, :integer
  end
end
