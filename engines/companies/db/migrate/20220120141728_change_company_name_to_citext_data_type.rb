# frozen_string_literal: true

class ChangeCompanyNameToCitextDataType < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_statement_timeout(3000)
  set_lock_timeout(2000)

  def up
    safety_assured do
      enable_extension "citext"
      change_column :companies_companies, :name, :citext
    end
  end

  def down
    safety_assured do
      disable_extension "citext"
      change_column :companies_companies, :name, :string
    end
  end
end
