# frozen_string_literal: true

class CreateTenantsMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants_memberships, id: :uuid do |t|
      t.references :member, polymorphic: true, index: true, type: :uuid
      t.uuid :group_id
      t.integer :priority, default: 0
      t.timestamps
    end
  end
end
