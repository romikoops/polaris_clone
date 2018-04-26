class CreateIncoterms < ActiveRecord::Migration[5.1]
  def change
    create_table :incoterms do |t|
      t.string :code
      t.string :description
      t.integer :incoterm_scope_id
      t.integer :incoterm_liability_id
      t.integer :incoterm_charge_id
      t.timestamps
    end
  end
end
