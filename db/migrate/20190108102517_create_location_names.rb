class CreateLocationNames < ActiveRecord::Migration[5.2]
  def change
    create_table :location_names do |t|
      t.string :language
      t.string :locality_2
      t.string :locality_3
      t.string :locality_4
      t.string :locality_5
      t.string :locality_6
      t.string :locality_7
      t.string :locality_8
      t.string :locality_9
      t.string :locality_10
      t.string :locality_11
      t.string :country
      t.string :postal_code
      t.string :name
      t.integer :location_id
      t.timestamps
    end
  end
end
