class BackfillDatesForShipments < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute("
        UPDATE shipments
        SET
          planned_etd = trips.start_date,
          planned_eta = trips.end_date,
          planned_origin_drop_off_date = trips.closing_date,
          planned_destination_collection_date = trips.end_date
        FROM trips
        WHERE trips.id = shipments.trip_id
        AND shipments.has_pre_carriage is FALSE
        AND shipments.has_on_carriage is FALSE
        AND shipments.planned_eta IS NULL
        AND shipments.planned_etd IS NULL
        AND shipments.trip_id IS NOT NULL
        AND shipments.status NOT IN ('booking_process_started', 'archived')
        ")
      execute("
        UPDATE shipments
        SET
          planned_etd = trips.start_date,
          planned_eta = trips.end_date,
          planned_pickup_date = trips.closing_date,
          planned_destination_collection_date = trips.end_date
        FROM trips
        WHERE trips.id = shipments.trip_id
        AND shipments.has_pre_carriage is TRUE
        AND shipments.has_on_carriage is FALSE
        AND shipments.planned_eta IS NULL
        AND shipments.planned_etd IS NULL
        AND shipments.trip_id IS NOT NULL
        AND shipments.status NOT IN ('booking_process_started', 'archived')
        ")
      execute("
          UPDATE shipments
          SET
            planned_etd = trips.start_date,
            planned_eta = trips.end_date,
            planned_origin_drop_off_date = trips.closing_date,
            planned_delivery_date = trips.end_date + interval '1 day'
          FROM trips
          WHERE trips.id = shipments.trip_id
          AND shipments.has_pre_carriage is FALSE
          AND shipments.has_on_carriage is TRUE
          AND shipments.planned_eta IS NULL
          AND shipments.planned_etd IS NULL
          AND shipments.trip_id IS NOT NULL
          AND shipments.status NOT IN ('booking_process_started', 'archived')
          ")
      execute("
          UPDATE shipments
          SET
            planned_etd = trips.start_date,
            planned_eta = trips.end_date,
            planned_pickup_date = trips.closing_date,
            planned_delivery_date = trips.end_date + interval '1 day'
          FROM trips
          WHERE trips.id = shipments.trip_id
          AND shipments.has_pre_carriage is TRUE
          AND shipments.has_on_carriage is TRUE
          AND shipments.planned_eta IS NULL
          AND shipments.planned_etd IS NULL
          AND shipments.trip_id IS NOT NULL
          AND shipments.status NOT IN ('booking_process_started', 'archived')
          ")
    end
  end

  def down
  end
end
