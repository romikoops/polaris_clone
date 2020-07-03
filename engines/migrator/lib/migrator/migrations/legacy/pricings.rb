# frozen_string_literal: true

module Migrator
  module Migrations
    module Legacy
      class Pricings < Base
        depends_on "organizations/organizations", "groups/groups"

        def data
          <<~SQL
            UPDATE pricings_margins
              SET applicable_type = CASE
                WHEN applicable_type = 'Tenants::Tenant' THEN 'Organizations::Organization'
                WHEN applicable_type = 'Tenants::Group' THEN 'Groups::Group'
                WHEN applicable_type = 'Tenants::User' THEN 'Organizations::Organization'
              END
              WHERE applicable_type NOT IN ('Organizations::Organization', 'Groups::Group', 'Organizations::Organization')
          SQL
        end
      end
    end
  end
end
