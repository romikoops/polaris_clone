# frozen_string_literal: true

class CreateTrackerInteractions < ActiveRecord::Migration[5.2]
  def change
    create_table :tracker_interactions, id: :uuid do |t|
      t.references :organization, type: :uuid, index: true, foreign_key: { to_table: "organizations_organizations" }
      t.string :name, null: false
      t.timestamps
    end
    add_index :tracker_interactions, %w[organization_id name], name: "index_interactions_on_organization_id", unique: true
  end
end
