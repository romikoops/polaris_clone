# frozen_string_literal: true

class CreateTrackerUsersInteractions < ActiveRecord::Migration[5.2]
  def change
    create_table :tracker_users_interactions, id: :uuid do |t|
      t.references :interaction, type: :uuid, index: true, foreign_key: { to_table: "tracker_interactions" }
      t.references :client, type: :uuid, index: true, foreign_key: { to_table: "users_clients" }
      t.timestamps
    end
    add_index :tracker_users_interactions, %w[client_id interaction_id], name: "index_users_interactions_on_client_id", unique: true
  end
end
