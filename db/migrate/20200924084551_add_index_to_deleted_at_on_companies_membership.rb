# frozen_string_literal: true

class AddIndexToDeletedAtOnCompaniesMembership < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :companies_memberships, :deleted_at, algorithm: :concurrently
  end
end
