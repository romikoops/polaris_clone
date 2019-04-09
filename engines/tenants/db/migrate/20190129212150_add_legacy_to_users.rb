# frozen_string_literal: true

class AddLegacyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants_users, :legacy_id, :integer
    add_column :tenants_users, :tenant_id, :uuid
  end
end
