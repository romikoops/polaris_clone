# frozen_string_literal: true

class AddPriorityToTenantsMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants_memberships, :priority, :integer, default: 0
  end
end
