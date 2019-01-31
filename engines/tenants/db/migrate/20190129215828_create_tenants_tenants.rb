# frozen_string_literal: true

class CreateTenantsTenants < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants_tenants, id: :uuid do |t|
      t.string :subdomain
      t.integer :legacy_id

      t.timestamps
    end
  end
end
