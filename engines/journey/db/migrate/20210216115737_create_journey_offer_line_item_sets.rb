# frozen_string_literal: true

class CreateJourneyOfferLineItemSets < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_offer_line_item_sets, id: :uuid do |t|
      t.references :offer, type: :uuid, index: true,
                           foreign_key: {on_delete: :cascade, to_table: "journey_offers"}
      t.references :line_item_set, type: :uuid, index: true,
                                   foreign_key: {on_delete: :cascade, to_table: "journey_line_item_sets"}
      t.timestamps
    end
  end
end
