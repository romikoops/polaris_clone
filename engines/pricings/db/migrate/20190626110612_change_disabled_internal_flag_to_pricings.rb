# frozen_string_literal: true

class ChangeDisabledInternalFlagToPricings < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :pricings_pricings, :disabled, :boolean }
    add_column :pricings_pricings, :internal, :boolean, default: false, index: true
  end
end
