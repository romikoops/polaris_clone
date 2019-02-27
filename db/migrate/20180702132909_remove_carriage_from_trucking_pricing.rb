# frozen_string_literal: true

class RemoveCarriageFromTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    remove_column :trucking_pricings, :carriage, :string
  end
end
