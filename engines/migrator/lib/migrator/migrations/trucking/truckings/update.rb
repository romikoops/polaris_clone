# frozen_string_literal: true

module Migrator
  module Migrations
    module Trucking
      module Truckings
        class Update < Base
          depends_on "trucking/truckings/backup"

          def organization_ids
            Organizations::Organization.ids
          end

          def data
            @statements ||= organization_ids.map { |organization_id|
              <<~SQL
                UPDATE trucking_truckings
                SET validity = daterange(DATE '2020-09-01', DATE '2021-12-31')
                WHERE deleted_at IS NULL
                AND validity IS NULL
                AND hub_id IS NOT NULL
                AND organization_id = '#{organization_id}';
              SQL
            }
          end

          def count_required
            @counts ||= organization_ids.map { |organization_id|
              count("
                  SELECT COUNT(*)
                  FROM trucking_truckings
                  WHERE deleted_at IS NULL
                  AND validity IS NULL
                  AND hub_id IS NOT NULL
                  AND organization_id = '#{organization_id}';
                ")
            }
          end
        end
      end
    end
  end
end
