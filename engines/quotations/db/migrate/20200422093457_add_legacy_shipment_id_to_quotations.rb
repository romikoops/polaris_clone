# frozen_string_literal: true

class AddLegacyShipmentIdToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_quotations, :legacy_shipment_id, :integer, index: true
  end
end
