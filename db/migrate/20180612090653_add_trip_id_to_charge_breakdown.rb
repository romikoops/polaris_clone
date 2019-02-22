# frozen_string_literal: true

class AddTripIdToChargeBreakdown < ActiveRecord::Migration[5.1]
  def change
    add_column :charge_breakdowns, :trip_id, :integer
  end
end
