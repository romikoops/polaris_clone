class OverhaulTruckingPricings < ActiveRecord::Migration[5.1]
  def change
    remove_column :trucking_pricings, :tenant_id
    remove_column :trucking_pricings, :nexus_id
    remove_column :trucking_pricings, :upper_zip
    remove_column :trucking_pricings, :lower_zip
    remove_column :trucking_pricings, :rate_table
    remove_column :trucking_pricings, :currency
    remove_column :trucking_pricings, :created_at
    remove_column :trucking_pricings, :updated_at
    remove_column :trucking_pricings, :province
    remove_column :trucking_pricings, :city
    remove_column :trucking_pricings, :rate_type
    remove_column :trucking_pricings, :dist_hub
    add_column :trucking_pricings, :hub_id, :integer
    add_column :trucking_pricings, :trucking_destination_id, :integer
    add_column :trucking_pricings, :courier_id, :integer
    add_column :trucking_pricings, :fees, :jsonb
  end
end
