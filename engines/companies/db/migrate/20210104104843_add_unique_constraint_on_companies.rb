# frozen_string_literal: true
class AddUniqueConstraintOnCompanies < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :companies_companies, [:organization_id, :name], unique: true, algorithm: :concurrently
  end
end
