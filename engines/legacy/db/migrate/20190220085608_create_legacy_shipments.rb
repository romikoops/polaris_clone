class CreateLegacyShipments < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_shipments, id: :uuid do |t|

      t.timestamps
    end
  end
end
