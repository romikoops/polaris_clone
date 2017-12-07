class CreateTransportTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :transport_types do |t|
        t.integer :vehicle_type_id
        t.string :mot
        t.string :name
      t.timestamps
    end
  end
end
