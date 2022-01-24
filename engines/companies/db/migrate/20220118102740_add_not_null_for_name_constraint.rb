# frozen_string_literal: true

class AddNotNullForNameConstraint < ActiveRecord::Migration[5.2]
  set_statement_timeout(3000)
  set_lock_timeout(2000)

  def up
    safety_assured do
      change_column_null :companies_companies, :name, false
    end
  end

  def down
    safety_assured do
      change_column_null :companies_companies, :name, true
    end
  end
end
