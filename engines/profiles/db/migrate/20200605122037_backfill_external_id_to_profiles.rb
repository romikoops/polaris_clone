# frozen_string_literal: true
class BackfillExternalIdToProfiles < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      exec_update <<~SQL
        UPDATE profiles_profiles
          SET external_id = users.external_id
        FROM tenants_users
        JOIN users ON users.id = tenants_users.legacy_id
        WHERE profiles_profiles.user_id = tenants_users.id
      SQL
    end
  end
end
