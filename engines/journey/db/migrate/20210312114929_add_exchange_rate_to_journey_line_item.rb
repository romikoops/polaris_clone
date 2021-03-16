class AddExchangeRateToJourneyLineItem < ActiveRecord::Migration[5.2]
  def change
    add_column :journey_line_items, :exchange_rate, :decimal
  end
end
