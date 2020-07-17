class TruckingMigrationJob < ApplicationJob
  concurrency 1, drop: false
  queue_as :default

  def perform(organization_id:) # rubocop:disable Metrics/MethodLength
    ActiveRecord::Base.connection.execute(
      <<-SQL
        INSERT INTO carriers (name, code, created_at, updated_at)
        SELECT COALESCE(couriers.name, organizations_organizations.slug), LOWER(COALESCE(couriers.name, organizations_organizations.slug)), current_timestamp, current_timestamp
        FROM trucking_couriers couriers
        JOIN organizations_organizations on couriers.organization_id = organizations_organizations.id
        WHERE organizations_organizations.id = '#{organization_id}'
        ON CONFLICT DO NOTHING
      SQL
    )
    ActiveRecord::Base.connection.execute(
      <<-SQL
        INSERT INTO tenant_vehicles (name, carrier_id, mode_of_transport, organization_id, created_at, updated_at)
        SELECT 'standard', c.id, 'truck_carriage', tc.organization_id, current_timestamp, current_timestamp
        FROM carriers c
        JOIN organizations_organizations on organizations_organizations.id  = '#{organization_id}'
        INNER JOIN trucking_couriers tc ON COALESCE(tc.name, organizations_organizations.slug) = c.name
        AND tc.organization_id = organizations_organizations.id
        ON CONFLICT DO NOTHING
      SQL
    )
    ActiveRecord::Base.connection.execute(
      <<-SQL
        UPDATE trucking_truckings
          SET tenant_vehicle_id = tenant_vehicles.id
        FROM tenant_vehicles
        INNER JOIN carriers on tenant_vehicles.carrier_id = carriers.id
        JOIN organizations_organizations on organizations_organizations.id  = '#{organization_id}'
        INNER JOIN trucking_couriers on COALESCE(trucking_couriers.name, organizations_organizations.slug) = carriers.name
        WHERE trucking_truckings.courier_id = trucking_couriers.id
        AND tenant_vehicles.mode_of_transport = 'truck_carriage'
        AND tenant_vehicles.organization_id = trucking_couriers.organization_id
        AND trucking_truckings.organization_id = organizations_organizations.id
      SQL
    )
  end
end
