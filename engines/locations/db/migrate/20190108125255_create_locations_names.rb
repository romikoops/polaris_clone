# frozen_string_literal: true

class CreateLocationsNames < ActiveRecord::Migration[5.2]
  def change
    create_table :locations_names, id: :uuid do |t|
      t.string 'language'
      t.integer 'osm_id', :limit => 8
      t.integer 'place_rank', :limit => 8
      t.string 'osm_type', index: true
      t.string 'street'
      t.string 'city'
      t.string 'country'
      t.string 'county'
      t.string 'state'
      t.string 'country_code'
      t.string 'display_name'
      t.string 'alternative_names'
      t.string 'name'
      t.geometry 'point'
      t.string 'postal_code'
      t.index "to_tsvector('english'::regconfig, (language)::text)", name: 'locations_names_to_tsvector_idx3', using: :gin
      t.index "to_tsvector('english'::regconfig, (osm_id)::text)", name: 'locations_names_to_tsvector_idx4', using: :gin
      t.index "to_tsvector('english'::regconfig, (country)::text)", name: 'locations_names_to_tsvector_idx1', using: :gin
      t.index "to_tsvector('english'::regconfig, (country_code)::text)", name: 'locations_names_to_tsvector_idx5', using: :gin
      t.index "to_tsvector('english'::regconfig, (display_name)::text)", name: 'locations_names_to_tsvector_idx6', using: :gin
      t.index "to_tsvector('english'::regconfig, (name)::text)", name: 'locations_names_to_tsvector_idx7', using: :gin
      t.index "to_tsvector('english'::regconfig, (alternative_names)::text)", name: 'locations_names_to_tsvector_idx8', using: :gin
      t.index "to_tsvector('english'::regconfig, (postal_code)::text)", name: 'locations_names_to_tsvector_idx9', using: :gin
      t.index "to_tsvector('english'::regconfig, (city)::text)", name: 'locations_names_to_tsvector_idx10', using: :gin
      t.index %w(language osm_id street country country_code display_name name postal_code), name: 'uniq_index_1', unique: true
      t.timestamps
    end
  end
end
