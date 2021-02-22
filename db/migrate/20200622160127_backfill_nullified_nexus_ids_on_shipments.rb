# frozen_string_literal: true
class BackfillNullifiedNexusIdsOnShipments < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      exec_update(
        <<~SQL
          UPDATE
            shipments
          SET
            origin_nexus_id = NULL
          WHERE
            id IN (
              SELECT
                shipments.id
              FROM
                shipments
                LEFT OUTER JOIN nexuses ON nexuses.id = shipments.origin_nexus_id
              WHERE
                nexuses.id IS NULL
                AND shipments.origin_nexus_id IS NOT NULL
            );
        SQL
      )

      exec_update(
        <<~SQL
          UPDATE
            shipments
          SET
            destination_nexus_id = NULL
          WHERE
            id IN (
              SELECT
                shipments.id
              FROM
                shipments
                LEFT OUTER JOIN nexuses ON nexuses.id = shipments.destination_nexus_id
              WHERE
                nexuses.id IS NULL
                AND shipments.destination_nexus_id IS NOT NULL
            );
        SQL
      )
    end
  end

  def down
  end
end
