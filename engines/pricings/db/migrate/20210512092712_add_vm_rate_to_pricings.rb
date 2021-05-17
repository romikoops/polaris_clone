# frozen_string_literal: true

class AddVmRateToPricings < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings_pricings, :vm_rate, :decimal
  end
end
