# frozen_string_literal: true

class AddGroupingAndZoneToTrucking < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_truckings, :target, :string
    add_column :trucking_truckings, :secondary, :string
    add_column :trucking_truckings, :zone, :string
  end
end
