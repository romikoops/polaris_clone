# frozen_string_literal: true

class BackfillProfilesForTenantsUser < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<-SQL
        INSERT INTO profiles_profiles (user_id, first_name, last_name, company_name, phone)
        SELECT tu.id, u.first_name, u.last_name, u.company_name, u.phone
        FROM tenants_users tu
        INNER JOIN users u ON u.id = tu.legacy_id
      SQL
    end
  end

  def down
  end
end
