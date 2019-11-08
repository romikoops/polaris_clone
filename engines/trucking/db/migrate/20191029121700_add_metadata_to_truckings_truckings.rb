# frozen_string_literal: true

class AddMetadataToTruckingsTruckings < ActiveRecord::Migration[5.2]
  def up
    add_column :trucking_truckings, :metadata, :jsonb
    change_column_default :trucking_truckings, :metadata, {}
  end

  def down
    remove_column :trucking_truckings, :metadata
  end
end
