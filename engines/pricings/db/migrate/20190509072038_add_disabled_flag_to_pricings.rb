# frozen_string_literal: true

class AddDisabledFlagToPricings < ActiveRecord::Migration[5.2]
  def up
    add_column :pricings_pricings, :disabled, :boolean
    change_column_default :pricings_pricings, :disabled, false
  end

  def down
    remove_column :pricings_pricings, :disabled
  end
end
