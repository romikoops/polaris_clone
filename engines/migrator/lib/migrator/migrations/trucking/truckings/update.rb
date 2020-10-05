# frozen_string_literal: true

module Migrator
  module Migrations
    module Trucking
      module Truckings
        class Update < Base
          def data
            organization_ids.map do |organization_id|
              <<~SQL
                INSERT INTO new_trucking_truckings
                SELECT *
                FROM trucking_truckings
                WHERE organization_id = '#{organization_id}'
                AND deleted_at IS NULL
                ON CONFLICT DO NOTHING;
              SQL
            end
          end

          def count_required
            organization_ids.map do |organization_id|
              count("
                SELECT COUNT(*)
                FROM trucking_truckings
                LEFT OUTER JOIN new_trucking_truckings
                ON new_trucking_truckings.organization_id = trucking_truckings.organization_id
                WHERE trucking_truckings.organization_id = '#{organization_id}'
                AND new_trucking_truckings.organization_id is NULL
                AND trucking_truckings.deleted_at IS NULL;
              ")
            end
          end

          def organization_ids
            @organization_ids ||= ::Organizations::Organization.ids
          end
        end
      end
    end
  end
end
