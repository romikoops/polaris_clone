# frozen_string_literal: true

class CreatePricingsLocationGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :pricings_location_groups, id: :uuid do |t|
      t.references :organization, type: :uuid, index: true,
                                  foreign_key: { to_table: "organizations_organizations", on_delete: :cascade },
                                  dependent: :destroy
      t.references :nexus, index: true, foreign_key: { to_table: "nexuses", on_delete: :cascade }, dependent: :destroy
      t.citext :name, null: false
      t.index %i[nexus_id name organization_id], unique: true, name: "index_organization_location_groups"
      t.timestamps
    end
  end
end
