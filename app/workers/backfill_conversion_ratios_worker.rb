# frozen_string_literal: true

class BackfillConversionRatiosWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    ActiveRecord::Base.connection.execute("
      UPDATE pricings_fees
      SET cbm_ratio = pricings_pricings.wm_rate, vm_ratio = pricings_pricings.vm_rate
      FROM pricings_pricings
      WHERE pricings_pricings.id = pricings_fees.pricing_id
    ")
  end
end
