# frozen_string_literal: true
class AddDeletedAtToTenantsUserAndCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants_users, :deleted_at, :datetime, index: true
    add_column :tenants_companies, :deleted_at, :datetime, index: true
  end
end
