# frozen_string_literal: true

class AddDesiredPickupDateToShipment < ActiveRecord::Migration[5.2]
  def change
    add_column :shipments, :desired_start_date, :datetime
  end
end
