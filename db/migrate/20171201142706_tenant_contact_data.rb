# frozen_string_literal: true

class TenantContactData < ActiveRecord::Migration[5.1]
  def up
    remove_column :tenants, :phone
    remove_column :tenants, :address
    add_column :tenants, :phones, :jsonb
    add_column :tenants, :addresses, :jsonb
  end
end
