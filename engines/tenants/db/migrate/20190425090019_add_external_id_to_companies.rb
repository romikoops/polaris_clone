# frozen_string_literal: true

class AddExternalIdToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants_companies, :external_id, :string
    add_column :tenants_companies, :phone, :string
  end
end
