class TruckingMigrationJob < ApplicationJob
  queue_as :default

  def perform(organization_id:) # rubocop:disable Metrics/MethodLength
    ActiveRecord::Base.connection.execute(
      <<-SQL
        INSERT INTO carriers (name, code, created_at, updated_at)
        SELECT couriers.name, LOWER(couriers.name), current_timestamp, current_timestamp
        FROM trucking_couriers couriers
        WHERE couriers.organization_id = '#{organization_id}'
        ON CONFLICT DO NOTHING
      SQL
    )
    ActiveRecord::Base.connection.execute(
      <<-SQL
        INSERT INTO tenant_vehicles (name, carrier_id, mode_of_transport, organization_id, created_at, updated_at)
        SELECT 'standard', c.id, 'truck_carriage', tc.organization_id, current_timestamp, current_timestamp
        FROM carriers c
        INNER JOIN trucking_couriers tc ON tc.name = c.name
        WHERE tc.organization_id = '#{organization_id}'
        ON CONFLICT DO NOTHING
      SQL
    )
    ActiveRecord::Base.connection.execute(
      <<-SQL
        UPDATE trucking_truckings
          SET tenant_vehicle_id = tenant_vehicles.id
        FROM tenant_vehicles
        INNER JOIN carriers on tenant_vehicles.carrier_id = carriers.id
        INNER JOIN trucking_couriers on trucking_couriers.name = carriers.name
        WHERE trucking_truckings.courier_id = trucking_couriers.id
        AND tenant_vehicles.mode_of_transport = 'carriage'
        AND tenant_vehicles.organization_id = trucking_couriers.organization_id
        AND tenant_vehicles.organization_id = trucking_truckings.organization_id
        AND tenant_vehicles.organization_id  = '#{organization_id}'
      SQL
    )
  end
end
