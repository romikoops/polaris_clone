# frozen_string_literal: true

class LegacyUsersToUsersUsersProfiles < ActiveRecord::Migration[5.2]
  TABLES = %w[
    profiles_profiles
  ]

  def change
    safety_assured do
      TABLES.each do |table|
        next if table[/_\d+\z/] || %w[migrator_syncs].include?(table)

        column = columns(table).find { |col| col.name == "user_id" }
        next unless column

        remove_foreign_key(table, :users) if foreign_key_exists?(table, :users)
        remove_foreign_key(table, :tenants_users) if foreign_key_exists?(table, :tenants_users)

        rename_column(table, :user_id, :legacy_user_id)
        change_column_null(table, :legacy_user_id, true)

        add_reference(table, :user, type: :uuid,
                                    index: true,
                                    foreign_key: {to_table: :users_users})
      end
    end
  end
end
