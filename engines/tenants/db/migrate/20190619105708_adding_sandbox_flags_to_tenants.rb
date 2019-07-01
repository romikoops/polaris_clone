# frozen_string_literal: true

class AddingSandboxFlagsToTenants < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants_companies, :sandbox_id, :uuid, index: true
    add_column :tenants_groups, :sandbox_id, :uuid, index: true
    add_column :tenants_memberships, :sandbox_id, :uuid, index: true
    add_column :tenants_scopes, :sandbox_id, :uuid, index: true
    add_column :tenants_users, :sandbox_id, :uuid, index: true
  end
end
