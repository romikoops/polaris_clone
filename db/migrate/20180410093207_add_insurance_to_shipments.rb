# frozen_string_literal: true

class AddInsuranceToShipments < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :insurance, :jsonb
  end
end
