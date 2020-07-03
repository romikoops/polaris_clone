# frozen_string_literal: true

class LegacyUsersToUsersUsers < ActiveRecord::Migration[5.2]
  TABLES = %w[
    contacts local_charges quotations shipments user_addresses user_managers
  ]

  def change
    safety_assured do
      TABLES.each do |table|
        next if table[/_\d+\z/] || %w[migrator_syncs].include?(table)

        column = columns(table).find { |col| col.name == "user_id" }
        next unless column

        remove_foreign_key(table, :users) if foreign_key_exists?(table, :users)

        rename_column(table, :user_id, :legacy_user_id)
        change_column_null(table, :legacy_user_id, true)

        add_reference(table, :user, type: :uuid,
                                    index: true,
                                    foreign_key: {to_table: :users_users})
      end
    end
  end
end
