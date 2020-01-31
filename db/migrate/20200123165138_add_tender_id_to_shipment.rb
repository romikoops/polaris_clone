# frozen_string_literal: true

class AddTenderIdToShipment < ActiveRecord::Migration[5.2]
  def change
    add_column :shipments, :tender_id, :uuid
  end
end
