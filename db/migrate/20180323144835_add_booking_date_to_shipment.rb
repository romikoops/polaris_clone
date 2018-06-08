# frozen_string_literal: true

class AddBookingDateToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :booking_placed_at, :datetime
  end
end
