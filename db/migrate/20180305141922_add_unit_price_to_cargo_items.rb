# frozen_string_literal: true

class AddUnitPriceToCargoItems < ActiveRecord::Migration[5.1]
  def change
    add_column :cargo_items, :unit_price, :jsonb
  end
end
