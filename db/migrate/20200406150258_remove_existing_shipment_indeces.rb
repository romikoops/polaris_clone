# frozen_string_literal: true

class RemoveExistingShipmentIndeces < ActiveRecord::Migration[5.2]
  def change
    remove_index :shipments, :sandbox_id
    remove_index :shipments, :tenant_id
    remove_index :shipments, :transport_category_id
  end
end
