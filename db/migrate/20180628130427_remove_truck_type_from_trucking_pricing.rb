# frozen_string_literal: true

class RemoveTruckTypeFromTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    remove_column :trucking_pricings, :truck_type, :string
  end
end
