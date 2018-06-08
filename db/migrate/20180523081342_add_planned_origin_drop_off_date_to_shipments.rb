# frozen_string_literal: true

class AddPlannedOriginDropOffDateToShipments < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :planned_origin_drop_off_date, :datetime
  end
end
