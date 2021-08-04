# frozen_string_literal: true

class AddChargeCategoryForeignKeyToFees < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :pricings_fees, :charge_categories, validate: false
  end
end
