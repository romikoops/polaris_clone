class DropBookingTables < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      drop_table :booking_offers
      drop_table :booking_queries
    end
  end
end
