# frozen_string_literal: true

class AddTenantName < ActiveRecord::Migration[5.1]
  def change
    add_column :tenants, :name, :string
  end
end
