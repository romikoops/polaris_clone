# frozen_string_literal: true

class AddLoadMeterageToTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    add_column :trucking_pricings, :load_meterage, :jsonb
    add_column :trucking_pricings, :cbm_ratio, :integer
  end
end
