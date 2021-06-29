# frozen_string_literal: true

class SoftdeleteDuplicatePricingsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    duplicates = Pricings::Pricing.where("(select count(*) from pricings_pricings inr where inr.upsert_id = pricings_pricings.upsert_id AND inr.validity && pricings_pricings.validity) > 1")
    total duplicates.count
    current_duplicates = duplicates.current
    current_duplicates.select(:upsert_id, :validity).distinct.each_with_index do |upsert_and_validity, index|
      conflicts = current_duplicates.where(upsert_id: upsert_and_validity.upsert_id).for_dates(upsert_and_validity.validity.first, upsert_and_validity.validity.last).order(created_at: :desc).to_a
      conflicts.shift
      conflicts.map(&:destroy)
      at index + 1, "Batch #{index}"
    end

    out_of_date_duplicates = duplicates.where("expiration_date < ?", Time.zone.today)

    Pricings::Fee.where(pricing_id: out_of_date_duplicates.ids).update_all(deleted_at: Time.zone.now)
    out_of_date_duplicates.update_all(deleted_at: Time.zone.now)
  end
end
