# frozen_string_literal: true

class AddDowncaseCheckForNameUniquenessConstraint < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_statement_timeout(3000)
  set_lock_timeout(2000)

  def up
    safety_assured do
      exec_update <<-SQL
        CREATE UNIQUE INDEX index_companies_companies_on_organization_id_and_name ON companies_companies(organization_id, LOWER(name)) WHERE deleted_at IS NULL;
      SQL
    end
  end

  def down
    safety_assured do
      remove_index :companies_companies, name: "index_companies_companies_on_organization_id_and_name"
    end
  end
end
