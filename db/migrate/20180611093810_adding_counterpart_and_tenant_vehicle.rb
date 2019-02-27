# frozen_string_literal: true

class AddingCounterpartAndTenantVehicle < ActiveRecord::Migration[5.1]
  def change
    add_column :local_charges, :tenant_vehicle_id, :integer
    add_column :customs_fees, :tenant_vehicle_id, :integer
    add_column :local_charges, :counterpart_hub_id, :integer
    add_column :customs_fees, :counterpart_hub_id, :integer
    add_column :local_charges, :direction, :string
    add_column :customs_fees, :direction, :string
    add_column :local_charges, :fees, :jsonb
    add_column :customs_fees, :fees, :jsonb
    remove_column :local_charges, :import, :jsonb
    remove_column :customs_fees, :import, :jsonb
    remove_column :local_charges, :export, :jsonb
    remove_column :customs_fees, :export, :jsonb
  end
end
