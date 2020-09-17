# frozen_string_literal: true

class CreateGroupsGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups_groups, id: :uuid do |t|
      t.string :name
      t.references :organization, type: :uuid, index: true,
                                  foreign_key: { to_table: "organizations_organizations" }

      t.timestamps
    end
  end
end
