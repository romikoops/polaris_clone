# frozen_string_literal: true

class CleanUpsertIdConflictsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    total duplicate_pairs.count
    duplicate_pairs.each.with_index do |record, index|
      at index + 1, "Dup Pair #{index + 1}"

      pricings = duplicates.where(
        itinerary_id: record.itinerary_id,
        organization_id: record.organization_id,
        tenant_vehicle_id: record.tenant_vehicle_id,
        cargo_class: record.cargo_class,
        group_id: record.group_id
      )

      pricings.pluck(:validity).uniq.each do |validity|
        temporal_duplicates = pricings.for_dates(validity.first, validity.last).order(created_at: :desc).to_a
        valid = temporal_duplicates.shift
        temporal_duplicates.map(&:destroy)
        valid.save
      end
    end
  end

  def duplicates
    Pricings::Pricing.where("(SELECT COUNT(*) FROM pricings_pricings inr WHERE inr.itinerary_id = pricings_pricings.itinerary_id AND inr.organization_id = pricings_pricings.organization_id AND inr.tenant_vehicle_id = pricings_pricings.tenant_vehicle_id AND inr.cargo_class = pricings_pricings.cargo_class AND inr.group_id = pricings_pricings.group_id AND inr.deleted_at IS NULL AND inr.validity && pricings_pricings.validity) > 1")
  end

  def duplicate_pairs
    @duplicate_pairs ||= duplicates.select(:itinerary_id, :organization_id, :tenant_vehicle_id, :cargo_class, :group_id).distinct.to_a
  end
end
