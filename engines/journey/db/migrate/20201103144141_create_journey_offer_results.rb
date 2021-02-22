# frozen_string_literal: true
class CreateJourneyOfferResults < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_offer_results, id: :uuid do |t|
      t.references :offer, type: :uuid, index: true,
                           foreign_key: {on_delete: :cascade, to_table: "journey_offers"}
      t.references :result, type: :uuid, index: true,
                            foreign_key: {on_delete: :cascade, to_table: "journey_results"}
      t.timestamps
    end
  end
end
