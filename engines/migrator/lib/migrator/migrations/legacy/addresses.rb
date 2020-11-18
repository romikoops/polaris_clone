# frozen_string_literal: true

module Migrator
  module Migrations
    module Legacy
      class Addresses < Base
        def data
          <<~SQL
            UPDATE addresses
              SET point = ST_SetSRID(ST_MakePoint(addresses.longitude, addresses.latitude), 4326)
            WHERE addresses.point is NULL
          SQL
        end

        def count_required
          count("SELECT count(*) FROM addresses
                 WHERE point IS NULL")
        end
      end
    end
  end
end
