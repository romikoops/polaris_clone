# frozen_string_literal: true

class AddPercentageToFees < ActiveRecord::Migration[5.2]
  def change
    add_column :rates_fees, :percentage, :decimal
  end
end
