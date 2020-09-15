# frozen_string_literal: true

module Migrator
  module Migrations
    module Pricings
      module Breakdowns
        class Update < Base
          def data
            <<~SQL
              UPDATE pricings_breakdowns
              SET target_type = CASE
                WHEN target_type = 'Tenants::Tenant' THEN 'Organizations::Organization'
                WHEN target_type = 'Tenants::Group' THEN 'Groups::Group'
                END
              WHERE target_type IN ('Tenants::Tenant', 'Tenants::Group')
            SQL
          end

          def count_required
            count("SELECT count(*) FROM pricings_breakdowns
                  WHERE target_type IN ('Tenants::Tenant', 'Tenants::Group')")
          end
        end
      end
    end
  end
end
