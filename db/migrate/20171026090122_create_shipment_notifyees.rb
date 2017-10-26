class CreateShipmentNotifyees < ActiveRecord::Migration[5.1]
  def change
    create_table :shipment_notifyees do |t|
    	t.integer :shipment_id
      t.integer :notifyee_id
      t.timestamps
    end
  end
end
