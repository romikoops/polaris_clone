class CreateServiceCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :service_charges do |t|
    	t.string :trade_direction
      t.string :container_size_class
      
      t.decimal :handling_documentation
      t.decimal :equipment_management_charges
      t.decimal :carrier_security_fee
      t.decimal :verified_gross_mass
      t.decimal :hazardous_cargo
      t.decimal :add_imo_position
      t.decimal :export_pickup_charge
      t.decimal :import_drop_off_charge
      t.timestamps
    end
  end
end
