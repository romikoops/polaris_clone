# frozen_string_literal: true

class RemoveLegacyColumnsFromShipments < ActiveRecord::Migration[5.1]
  def change
    remove_column :shipments, :pre_carriage_distance_km, :decimal
    remove_column :shipments, :on_carriage_distance_km, :decimal
    remove_column :shipments, :haulage, :string
    remove_column :shipments, :schedules_charges, :jsonb
    remove_column :shipments, :schedule_set, :jsonb
    remove_column :shipments, :route_id, :integer
    remove_column :shipments, :hs_code, :string
  end
end
