# frozen_string_literal: true

class AddUnitPriceToContainers < ActiveRecord::Migration[5.1]
  def change
    add_column :containers, :unit_price, :jsonb
  end
end
