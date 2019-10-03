# frozen_string_literal: true

class AddPricingsPricingIdToNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :notes, :pricings_pricing_id, :uuid
  end
end
