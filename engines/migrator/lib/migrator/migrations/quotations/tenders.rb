# frozen_string_literal: true

module Migrator
  module Migrations
    module Quotations
      class Tenders < Base
        def data
          <<~SQL
            UPDATE quotations_tenders
            SET imc_reference = shipmentS.imc_reference
            FROM charge_breakdowns
            RIGHT JOIN shipments ON charge_breakdowns.shipment_id = shipments.id
            WHERE charge_breakdowns.tender_id = quotations_tenders.id
            AND quotations_tenders.imc_reference IS NULL
            AND shipments.imc_reference IS NOT NULL
            AND shipments.deleted_at IS NULL
          SQL
        end

        def count_required
          count("SELECT COUNT(*) FROM quotations_tenders
                 WHERE quotations_tenders.id IN (SELECT quotations_tenders.id
                 FROM quotations_tenders
                 JOIN charge_breakdowns ON quotations_tenders.id = charge_breakdowns.tender_id
                 JOIN shipments ON charge_breakdowns.shipment_id = shipments.id
                 WHERE quotations_tenders.imc_reference IS NULL
                 AND shipments.imc_reference IS NOT NULL
                 AND shipments.deleted_at IS NULL)")
        end
      end
    end
  end
end
