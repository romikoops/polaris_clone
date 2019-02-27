# frozen_string_literal: true

class RemoveItineraryIdFromChargeBreakdown < ActiveRecord::Migration[5.1]
  def change
    remove_column :charge_breakdowns, :itinerary_id, :integer
  end
end
