# frozen_string_literal: true

class AddDistinctIdToShipments < ActiveRecord::Migration[5.2]
  def change
    add_column :shipments, :distinct_id, :uuid
    add_column :quotations, :distinct_id, :uuid
  end
end
