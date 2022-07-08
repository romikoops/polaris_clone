# frozen_string_literal: true

class RemoveOrganizationFromInteraction < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :tracker_interactions, :organization_id
      add_index :tracker_interactions, :name, unique: true
    end
  end
end
