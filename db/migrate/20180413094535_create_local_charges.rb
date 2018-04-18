class CreateLocalCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :local_charges do |t|
      t.jsonb :import
      t.jsonb :export
      t.string :mode_of_transport
      t.string :load_type
      t.integer :hub_id
      t.integer :tenant_id
      t.timestamps
    end
  end
end
