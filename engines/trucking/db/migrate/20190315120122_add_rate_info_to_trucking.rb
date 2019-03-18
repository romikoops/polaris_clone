# frozen_string_literal: true

class AddRateInfoToTrucking < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_truckings, :load_meterage, :jsonb
    add_column :trucking_truckings, :cbm_ratio, :integer
    add_column :trucking_truckings, :modifier, :string
    add_column :trucking_truckings, :tenant_id, :integer
    add_column :trucking_truckings, :rates, :jsonb
    add_column :trucking_truckings, :fees, :jsonb
    add_column :trucking_truckings, :identifier_modifier, :string
    add_column :trucking_truckings, :load_type, :string, index: true
    add_column :trucking_truckings, :cargo_class, :string, index: true
    add_column :trucking_truckings, :carriage, :string, index: true
    add_column :trucking_truckings, :courier_id, :uuid
    add_column :trucking_truckings, :truck_type, :string, index: true
    add_column :trucking_truckings, :user_id, :integer, index: true
  end
end
