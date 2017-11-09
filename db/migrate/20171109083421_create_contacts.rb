class CreateContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :contacts do |t|
      t.integer :shipper_id
      t.integer :location_id

      t.string :company_name
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.timestamps
    end
  end
end
