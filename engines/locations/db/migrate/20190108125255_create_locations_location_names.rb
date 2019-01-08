class CreateLocationsLocationNames < ActiveRecord::Migration[5.2]
  def change
    create_table :locations_location_names, id: :uuid do |t|
      t.string "language"
      t.string "locality_2"
      t.string "locality_3"
      t.string "locality_4"
      t.string "locality_5"
      t.string "locality_6"
      t.string "locality_7"
      t.string "locality_8"
      t.string "locality_9"
      t.string "locality_10"
      t.string "locality_11"
      t.string "country"
      t.string "postal_code"
      t.string "name"
      t.integer "location_id"
      t.index "to_tsvector('english'::regconfig, (locality_2)::text)", name: "locations_location_names_to_tsvector_idx3", using: :gin
      t.index "to_tsvector('english'::regconfig, (locality_3)::text)", name: "locations_location_names_to_tsvector_idx4", using: :gin
      t.index "to_tsvector('english'::regconfig, (locality_4)::text)", name: "locations_location_names_to_tsvector_idx2", using: :gin
      t.index "to_tsvector('english'::regconfig, (locality_5)::text)", name: "locations_location_names_to_tsvector_idx1", using: :gin
      t.index "to_tsvector('english'::regconfig, (locality_6)::text)", name: "locations_location_names_to_tsvector_idx1", using: :gin
      t.index "to_tsvector('english'::regconfig, (locality_7)::text)", name: "locations_location_names_to_tsvector_idx1", using: :gin
      t.index "to_tsvector('english'::regconfig, (locality_8)::text)", name: "locations_location_names_to_tsvector_idx1", using: :gin
      t.index "to_tsvector('english'::regconfig, (locality_9)::text)", name: "locations_location_names_to_tsvector_idx1", using: :gin
      t.index "to_tsvector('english'::regconfig, (locality_10)::text)", name: "locations_location_names_to_tsvector_idx1", using: :gin
      t.index "to_tsvector('english'::regconfig, (locality_11)::text)", name: "locations_location_names_to_tsvector_idx1", using: :gin
      t.index "to_tsvector('english'::regconfig, (postal_code)::text)", name: "locations_location_names_to_tsvector_idx", using: :gin
      t.index "to_tsvector('english'::regconfig, (name)::text)", name: "locations_location_names_to_tsvector_idx", using: :gin
      t.index ["locality_2", "locality_3", "locality_4", "locality_5", "locality_6", "locality_7", "locality_8", "locality_9", "locality_10", "locality_11", "country", "postal_code", "name"], name: "uniq_index", unique: true
      t.timestamps
    end
  end
end
