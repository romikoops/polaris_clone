# frozen_string_literal: true

class CreateLegacyShipments < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_shipments, id: :uuid, &:timestamps
  end
end
