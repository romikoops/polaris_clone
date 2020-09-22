# frozen_string_literal: true

module Migrator
  module Migrations
    module Trucking
      module Locations
        class Update < Base
          depends_on "trucking/locations/backup"

          def data
            <<~SQL
              UPDATE trucking_truckings
              SET location_id = migrator_unique_trucking_location_syncs.unique_trucking_location_id
              FROM migrator_unique_trucking_location_syncs
              WHERE trucking_truckings.location_id = migrator_unique_trucking_location_syncs.duplicate_trucking_location_id
              AND trucking_truckings.location_id != migrator_unique_trucking_location_syncs.unique_trucking_location_id
            SQL
          end

          def count_required
            count("
              SELECT COUNT(*)
              FROM trucking_locations
              JOIN migrator_unique_trucking_location_syncs
              ON trucking_locations.id = migrator_unique_trucking_location_syncs.duplicate_trucking_location_id
              JOIN trucking_truckings ON trucking_truckings.location_id = trucking_locations.id
              WHERE trucking_locations.id != migrator_unique_trucking_location_syncs.unique_trucking_location_id;
            ")
          end
        end
      end
    end
  end
end
