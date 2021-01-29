class AddQueryRealtionToOffer < ActiveRecord::Migration[5.2]

  def change
    safety_assured do
      add_reference :journey_offers, :query, foreign_key: {to_table: :journey_queries}, type: :uuid
    end
  end
end