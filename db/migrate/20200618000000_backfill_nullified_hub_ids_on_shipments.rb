class BackfillNullifiedHubIdsOnShipments < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      exec_update(
        <<~SQL
          UPDATE
            shipments
          SET
            origin_hub_id = NULL
          WHERE
            id IN (
              SELECT
                shipments.id
              FROM
                shipments
                LEFT OUTER JOIN hubs ON hubs.id = shipments.origin_hub_id
              WHERE
                hubs.id IS NULL
                AND shipments.origin_hub_id IS NOT NULL
            );
        SQL
      )

      exec_update(
        <<~SQL
          UPDATE
            shipments
          SET
            destination_hub_id = NULL
          WHERE
            id IN (
              SELECT
                shipments.id
              FROM
                shipments
                LEFT OUTER JOIN hubs ON hubs.id = shipments.destination_hub_id
              WHERE
                hubs.id IS NULL
                AND shipments.destination_hub_id IS NOT NULL
            );
        SQL
      )
    end
  end

  def down
  end
end
