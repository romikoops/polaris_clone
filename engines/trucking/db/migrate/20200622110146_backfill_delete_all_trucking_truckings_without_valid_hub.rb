class BackfillDeleteAllTruckingTruckingsWithoutValidHub < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      exec_delete(
        <<~SQL
          DELETE FROM
            trucking_truckings
          WHERE
            id IN (
              SELECT
                trucking_truckings.id
              FROM
                trucking_truckings
                LEFT OUTER JOIN hubs ON trucking_truckings.hub_id = hubs.id
              WHERE
                hubs.id IS NULL
            );
        SQL
      )
    end
  end

  def down
  end
end
