# frozen_string_literal: true

class AddingSandboxFlagsToTrucking < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_couriers, :sandbox_id, :uuid, index: true
    add_column :trucking_coverages, :sandbox_id, :uuid, index: true
    add_column :trucking_destinations, :sandbox_id, :uuid, index: true
    add_column :trucking_hub_availabilities, :sandbox_id, :uuid, index: true
    add_column :trucking_locations, :sandbox_id, :uuid, index: true
    add_column :trucking_truckings, :sandbox_id, :uuid, index: true
    add_column :trucking_type_availabilities, :sandbox_id, :uuid, index: true
  end
end
