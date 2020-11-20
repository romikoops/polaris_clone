# frozen_string_literal: true

class AddTenantsIndices < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    %i[
      addons agencies charge_categories contents conversations couriers currencies customs_fees documents hubs
      local_charges map_data max_dimensions_bundles nexuses pricings_fees shipments tenant_incoterms
      tenant_routing_connections tenant_routing_routes tenant_vehicles tenants_companies tenants_domains tenants_groups
      tenants_sandboxes tenants_users trucking_couriers trucking_pricings trucking_rates users
    ].each do |table|
      add_index table, :tenant_id, algorithm: :concurrently
    end
  end
end
