# frozen_string_literal: true

module Migrator
  module Migrations
    module Quotations
      module Quotations
        class Update < Base
          def data
            <<~SQL
              UPDATE quotations_quotations
              SET user_id = shipments.user_id, creator_id = shipments.user_id
              FROM shipments 
              WHERE quotations_quotations.legacy_shipment_id = shipments.id
              AND shipments.user_id IS NOT NULL
              AND quotations_quotations.user_id IS NULL
              AND quotations_quotations.creator_id IS NULL
            SQL
          end

          def count_required
            count("
                SELECT COUNT(*)
                FROM quotations_quotations
                JOIN shipments
                ON quotations_quotations.legacy_shipment_id = shipments.id
                WHERE shipments.user_id IS NOT NULL
                AND quotations_quotations.user_id IS NULL
                AND quotations_quotations.creator_id IS NULL
            ")
          end
        end
      end
    end
  end
end
