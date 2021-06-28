# frozen_string_literal: true

class BackfillUpsertIdOnPricingsAndFeesWorker
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE pricings_pricings
        SET upsert_id = uuid_generate_v5('#{Pricings::Pricing::UUID_V5_NAMESPACE}', CONCAT(itinerary_id::text, tenant_vehicle_id::text, cargo_class::text, group_id::text, organization_id::text)::text)
      SQL
    )
    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE pricings_fees
        SET upsert_id = uuid_generate_v5('#{Pricings::Fee::UUID_V5_NAMESPACE}', CONCAT(pricing_id::text, charge_category_id::text, organization_id::text)::text)
      SQL
    )
  end
end
