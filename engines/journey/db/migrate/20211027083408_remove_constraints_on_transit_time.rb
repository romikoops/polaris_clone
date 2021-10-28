# frozen_string_literal: true

class RemoveConstraintsOnTransitTime < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      change_column_default(:journey_route_sections, :transit_time, 0)
      change_column_null(:journey_route_sections, :transit_time, true)
    end
  end
end
