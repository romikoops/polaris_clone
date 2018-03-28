class CreateCouriers < ActiveRecord::Migration[5.1]
  def change
    create_table :couriers do |t|
      t.string :name
      t.integer :tenant_id
      t.timestamps
    end
  end
end
