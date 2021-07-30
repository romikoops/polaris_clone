# frozen_string_literal: true

class ClearAllInvalidPricingsFeesWorker
  include Sidekiq::Worker

  def perform
    fallback_charge_category = Legacy::ChargeCategory.find_or_create_by(name: "Placeholder for Missing ChargeCategory", code: "missing_cc")
    Pricings::Fee.with_deleted.where(charge_category_id: nil).find_each do |fee|
      fee.update(charge_category: fallback_charge_category)
      fee.destroy unless fee.paranoia_destroyed?
    end
  end
end
