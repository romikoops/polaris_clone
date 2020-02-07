# frozen_string_literal: true

class AddTenderIdToChargeBreakdowns < ActiveRecord::Migration[5.2]
  def change
    add_column :charge_breakdowns, :tender_id, :uuid
  end
end
