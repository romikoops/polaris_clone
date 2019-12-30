# frozen_string_literal: true

class AddValdiityDateToChargeBreakdown < ActiveRecord::Migration[5.2]
  def change
    add_column :charge_breakdowns, :valid_until, :datetime
  end
end
