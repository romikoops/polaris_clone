# frozen_string_literal: true

class CreateGroupsMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :groups_memberships, id: :uuid do |t|
      t.references :member, type: :uuid, polymorphic: true, index: true
      t.references :group, type: :uuid, index: true,
                           foreign_key: {to_table: "groups_groups"}
      t.integer :priority

      t.timestamps
    end
  end
end
