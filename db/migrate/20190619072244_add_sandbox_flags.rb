# frozen_string_literal: true

class AddSandboxFlags < ActiveRecord::Migration[5.2]
  def change
    add_column :shipments, :sandbox_id, :uuid, index: true
    add_column :addresses, :sandbox_id, :uuid, index: true
    add_column :aggregated_cargos, :sandbox_id, :uuid, index: true
    add_column :cargo_items, :sandbox_id, :uuid, index: true
    add_column :carriers, :sandbox_id, :uuid, index: true
    add_column :charges, :sandbox_id, :uuid, index: true
    add_column :charge_categories, :sandbox_id, :uuid, index: true
    add_column :charge_breakdowns, :sandbox_id, :uuid, index: true
    add_column :contacts, :sandbox_id, :uuid, index: true
    add_column :containers, :sandbox_id, :uuid, index: true
    add_column :couriers, :sandbox_id, :uuid, index: true
    add_column :documents, :sandbox_id, :uuid, index: true
    add_column :hubs, :sandbox_id, :uuid, index: true
    add_column :itineraries, :sandbox_id, :uuid, index: true
    add_column :layovers, :sandbox_id, :uuid, index: true
    add_column :map_data, :sandbox_id, :uuid, index: true
    add_column :max_dimensions_bundles, :sandbox_id, :uuid, index: true
    add_column :nexuses, :sandbox_id, :uuid, index: true
    add_column :notes, :sandbox_id, :uuid, index: true
    add_column :optin_statuses, :sandbox_id, :uuid, index: true
    add_column :prices, :sandbox_id, :uuid, index: true
    add_column :pricing_details, :sandbox_id, :uuid, index: true
    add_column :pricings, :sandbox_id, :uuid, index: true
    add_column :remarks, :sandbox_id, :uuid, index: true
    add_column :shipment_contacts, :sandbox_id, :uuid, index: true
    add_column :stops, :sandbox_id, :uuid, index: true
    add_column :tenant_cargo_item_types, :sandbox_id, :uuid, index: true
    add_column :tenant_vehicles, :sandbox_id, :uuid, index: true
    add_column :transport_categories, :sandbox_id, :uuid, index: true
    add_column :trips, :sandbox_id, :uuid, index: true
    add_column :users, :sandbox_id, :uuid, index: true
    add_column :local_charges, :sandbox_id, :uuid, index: true
    add_column :quotations, :sandbox_id, :uuid, index: true
  end
end
