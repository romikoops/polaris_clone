# frozen_string_literal: true
class CreateRoutingTransitTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :routing_transit_times, id: :uuid do |t|
      t.uuid :route_line_service_id
      t.decimal :days
      t.timestamps
    end
  end
end
