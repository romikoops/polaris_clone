# frozen_string_literal: true

class CorrectRouteSectionTransitTimeDefault < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      change_column_default(:journey_route_sections, :transit_time, nil)
    end
  end
end
