# frozen_string_literal: true

class LegacyTenantToOrganizationsRmsData < ActiveRecord::Migration[5.2]
  TABLES = %w[
    rms_data_books rms_data_cells rms_data_sheets
  ]

  def up
    safety_assured do
      TABLES.each do |table|
        next if table[/_\d+\z/] || table.starts_with?("migrator_")

        column = columns(table).find { |col| col.name == "tenant_id" }
        next unless column

        remove_foreign_key(table, :tenants) if foreign_key_exists?(table, :tenants)
        remove_foreign_key(table, :tenants_tenants) if foreign_key_exists?(table, :tenants_tenants)

        add_reference(table, :organization, type: :uuid,
                                            index: true,
                                            foreign_key: {to_table: :organizations_organizations})
        change_column_null(table, :tenant_id, true)
      end
    end
  end
end
