# frozen_string_literal: true
class DropUnusedTablesAndColumns < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      remove_columns :active_storage_attachments, :record_type_20200211,
        :record_id_20200211
      remove_columns :users, :company_name_20200207, :first_name_20200207,
        :last_name_20200207, :phone_20200207

      drop_table :migrator_syncs
      drop_table :migrator_unique_carrier_syncs
      drop_table :migrator_unique_locations_locations_syncs
      drop_table :migrator_unique_tenant_vehicles_syncs
      drop_table :migrator_unique_trucking_location_syncs
      drop_table :migrator_unique_trucking_syncs
    end
  end
end
