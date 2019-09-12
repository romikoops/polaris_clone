# frozen_string_literal: true

class AddSandboxIndices < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    %i(addresses aggregated_cargos cargo_items carriers charge_breakdowns charge_categories charges contacts containers
       couriers documents hubs itineraries layovers local_charges map_data max_dimensions_bundles nexuses notes
       optin_statuses prices pricing_details pricings pricings_details pricings_fees pricings_margins pricings_pricings
       pricings_rate_bases quotations remarks shipment_contacts shipments stops tenant_cargo_item_types tenant_vehicles
       tenants_companies tenants_groups tenants_memberships tenants_scopes tenants_users transport_categories trips
       trucking_couriers trucking_coverages trucking_destinations trucking_hub_availabilities trucking_locations
       trucking_truckings trucking_type_availabilities users).each do |table|
      add_index table, :sandbox_id, algorithm: :concurrently
    end
  end
end
