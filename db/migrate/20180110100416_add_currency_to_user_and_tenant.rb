# frozen_string_literal: true

class AddCurrencyToUserAndTenant < ActiveRecord::Migration[5.1]
  def change
    add_column :tenants, :currency, :string, default: "EUR"
    add_column :users, :currency, :string, default: "EUR"
  end
end
