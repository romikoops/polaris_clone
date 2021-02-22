# frozen_string_literal: true
class BackfillShipmentsBookingPlacedAt < ActiveRecord::Migration[5.2]
  def up
    exec_update <<~SQL
      UPDATE shipments
      SET booking_placed_at = shipments.created_at
      WHERE status = 'quoted'
      AND booking_placed_at IS null
    SQL
  end

  def down
  end
end
