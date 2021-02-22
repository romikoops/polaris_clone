# frozen_string_literal: true
class AddUniqueIndexOnCompaniesMemberships < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :companies_memberships, [:member_id, :company_id], unique: true, algorithm: :concurrently
  end
end
