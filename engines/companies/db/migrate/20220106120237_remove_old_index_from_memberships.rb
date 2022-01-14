# frozen_string_literal: true

class RemoveOldIndexFromMemberships < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_statement_timeout(3000)
  set_lock_timeout(2000)

  def change
    remove_index :companies_memberships, name: :index_companies_memberships_on_member_id_and_company_id, algorithm: :concurrently
  end
end
