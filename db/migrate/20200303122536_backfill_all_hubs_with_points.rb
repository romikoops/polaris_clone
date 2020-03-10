# frozen_string_literal: true

class BackfillAllHubsWithPoints < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      exec_update <<~SQL
        UPDATE hubs
          SET point = ST_SetSRID(ST_MakePoint(hubs.longitude, hubs.latitude), 4326)
         WHERE hubs.point is NULL
      SQL
    end
  end
end
