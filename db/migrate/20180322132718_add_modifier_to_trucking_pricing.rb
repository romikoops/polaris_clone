# frozen_string_literal: true

class AddModifierToTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    add_column :trucking_pricings, :modifier, :string
  end
end
