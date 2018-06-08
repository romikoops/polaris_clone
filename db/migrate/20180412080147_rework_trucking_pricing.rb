# frozen_string_literal: true

class ReworkTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    remove_column :trucking_pricings, :direction, :string
    add_column :trucking_pricings, :carriage, :string
    remove_column :trucking_pricings, :export, :jsonb
    remove_column :trucking_pricings, :import, :jsonb
    add_column :trucking_pricings, :rates, :jsonb
    add_column :trucking_pricings, :fees, :jsonb
  end
end
