# frozen_string_literal: true

class AddCustomsCreditToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :customs_credit, :boolean, default: false
  end
end
