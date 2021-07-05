# frozen_string_literal: true

class DedupePricingsFeesWorker
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE pricings_fees
        SET deleted_at = now()
        WHERE pricings_fees.pricing_id IS NULL
        AND pricings_fees.deleted_at IS NULL;
      SQL
    )
    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE pricings_fees
        SET deleted_at = now()
        FROM pricings_pricings
        WHERE pricings_pricings.id = pricings_fees.pricing_id
        AND pricings_fees.pricing_id IS NOT NULL
        AND pricings_fees.deleted_at IS NULL;
      SQL
    )
    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE pricings_fees
        SET deleted_at = now()
        WHERE pricings_fees.pricing_id NOT IN (
          SELECT pricings_pricings.id FROM pricings_pricings
        )
        AND pricings_fees.deleted_at IS NULL;
      SQL
    )
    ActiveRecord::Base.connection.execute(
      <<~SQL
        WITH sorted_pricings_fees AS (
        SELECT pricings_fees.id AS duplicate_id, FIRST_VALUE(pricings_fees.id) OVER (
            PARTITION BY (pricings_fees.upsert_id)
            ORDER BY pricings_fees.created_at DESC
        ) unique_id
            FROM pricings_fees
            JOIN pricings_pricings
            ON pricings_pricings.id = pricings_fees.pricing_id
            WHERE pricings_pricings.deleted_at IS NULL
            AND pricings_fees.deleted_at IS NULL
        )

        UPDATE pricings_fees
        SET deleted_at = now()
        FROM sorted_pricings_fees
        WHERE pricings_fees.id = sorted_pricings_fees.duplicate_id
        AND pricings_fees.id != sorted_pricings_fees.unique_id
        AND pricings_fees.deleted_at IS NULL;
      SQL
    )
  end
end
