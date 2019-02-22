# frozen_string_literal: true

class AddIdenitifierModifierToTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    add_column :trucking_pricings, :identifier_modifier, :string
  end
end
