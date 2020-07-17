# frozen_string_literal: true

class BackfillingWmRatios < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    exec_update <<~SQL
      UPDATE pricings_pricings
      SET wm_rate = CASE
                      WHEN itineraries.mode_of_transport = 'ocean' THEN 1000
                      WHEN itineraries.mode_of_transport = 'air' THEN 167
                      WHEN itineraries.mode_of_transport = 'rail' THEN 500
                      WHEN itineraries.mode_of_transport = 'truck' THEN 333
                    END
      FROM itineraries
      WHERE wm_rate IS NULL
      AND itineraries.id = pricings_pricings.itinerary_id
    SQL
  end
end
