class CreateIncotermCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :incoterm_charges do |t|
      t.boolean :origin
      t.boolean :destination
      t.boolean :pre_carriage
      t.boolean :on_carriage
      t.boolean :freight, default: true
      t.timestamps
    end
  end
end
