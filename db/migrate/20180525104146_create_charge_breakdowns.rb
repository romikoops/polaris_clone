class CreateChargeBreakdowns < ActiveRecord::Migration[5.1]
  def change
    create_table :charge_breakdowns do |t|
      t.integer :shipment_id
      t.integer :itinerary_id

      t.timestamps
    end
  end
end
