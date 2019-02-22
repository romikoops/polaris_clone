# frozen_string_literal: true

class AddTenantToCurrencies < ActiveRecord::Migration[5.1]
  def change
    add_column :currencies, :tenant_id, :integer
  end
end
