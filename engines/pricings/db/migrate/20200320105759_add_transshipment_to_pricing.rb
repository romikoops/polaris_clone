# frozen_string_literal: true

class AddTransshipmentToPricing < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings_pricings, :transshipment, :string
  end
end
