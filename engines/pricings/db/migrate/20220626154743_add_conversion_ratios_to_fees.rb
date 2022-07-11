# frozen_string_literal: true

class AddConversionRatiosToFees < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings_fees, :cbm_ratio, :decimal, precision: 10, scale: 2
    add_column :pricings_fees, :vm_ratio, :decimal, precision: 10, scale: 2
  end
end
