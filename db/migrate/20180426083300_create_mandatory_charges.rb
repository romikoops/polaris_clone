class CreateMandatoryCharges < ActiveRecord::Migration[5.1]
  def change
    add_column :hubs, :mandatory_charge_id, :integer
    create_table :mandatory_charges do |t|
      t.boolean :pre_carriage
      t.boolean :on_carriage
      t.boolean :import_charges
      t.boolean :export_charges
      t.timestamps
    end
  end
end
