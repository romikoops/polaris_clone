# frozen_string_literal: true

class DropTransitTimes < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_table :routing_transit_times, 'routing_transit_times_20191213111544'
    end
  end
end
