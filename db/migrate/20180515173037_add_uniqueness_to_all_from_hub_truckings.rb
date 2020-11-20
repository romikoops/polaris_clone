# frozen_string_literal: true

class AddUniquenessToAllFromHubTruckings < ActiveRecord::Migration[5.1]
  def change
    add_index :hub_truckings,
      %i[trucking_pricing_id trucking_destination_id hub_id],
      name: "foreign_keys",
      unique: true
  end
end
