class CreateJourneyOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_offers, id: :uuid do |t|
      t.timestamps
    end
  end
end
