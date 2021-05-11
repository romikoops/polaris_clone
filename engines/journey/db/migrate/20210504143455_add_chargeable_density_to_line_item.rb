# frozen_string_literal: true

class AddChargeableDensityToLineItem < ActiveRecord::Migration[5.2]
  def change
    add_column :journey_line_items, :chargeable_density, :decimal
    change_column_null :journey_line_items, :wm_rate, true
  end
end
