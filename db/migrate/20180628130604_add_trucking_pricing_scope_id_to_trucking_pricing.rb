# frozen_string_literal: true

class AddTruckingPricingScopeIdToTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    add_column :trucking_pricings, :trucking_pricing_scope_id, :integer, index: true
  end
end
