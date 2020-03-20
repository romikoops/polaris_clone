# frozen_string_literal: true

class BackfillPricingsTransshipment < ActiveRecord::Migration[5.2]
  def up
    exec_update <<~SQL
      UPDATE pricings_pricings
      SET transshipment = notes.body
      FROM notes
      WHERE notes.pricings_pricing_id = pricings_pricings.id AND notes.transshipment = true
    SQL
  end

  def down
    Pricings::Pricing.where.not(transshipment: nil).update(transshipment: nil)
  end
end
