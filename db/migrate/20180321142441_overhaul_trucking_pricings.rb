# frozen_string_literal: true

class OverhaulTruckingPricings < ActiveRecord::Migration[5.1]
  def up
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
    add_column :trucking_pricings, :export, :jsonb
    add_column :trucking_pricings, :import, :jsonb
    add_column :trucking_pricings, :courier_id, :integer
    add_column :trucking_pricings, :direction, :string
    add_column :trucking_pricings, :load_type, :string
  end
end
