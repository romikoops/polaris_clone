# frozen_string_literal: true

# This class exists to clean the Itinerary table prior to applying a db level uniqueness constraint.
class DedupeItinerariesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  FailedDeduping = Class.new(StandardError)

  def perform
    itinerary_pairs = duplicates.select(:origin_hub_id, :destination_hub_id, :mode_of_transport, :transshipment, :organization_id).distinct
    pair_total_count = itinerary_pairs.length
    total pair_total_count

    itinerary_pairs.each_with_index do |record, index|
      invalid_itineraries = Legacy::Itinerary.where(
        origin_hub_id: record.origin_hub_id,
        destination_hub_id: record.destination_hub_id,
        mode_of_transport: record.mode_of_transport,
        transshipment: record.transshipment,
        organization_id: record.organization_id
      ).sort_by { |itinerary| -itinerary.rates.count }
      valid_itinerary = invalid_itineraries.shift
      update_invalid_itineraries(valid_id: valid_itinerary.id, invalid_itineraries: invalid_itineraries)
      render_index = index + 1
      at render_index, "Hub #{valid_itinerary.name} #{render_index} / #{pair_total_count} done"
    end

    raise FailedDeduping unless duplicates.empty?
  end

  def update_invalid_itineraries(valid_id:, invalid_itineraries:)
    ActiveRecord::Base.transaction do
      # rubocop:disable Rails/SkipsModelValidations
      Legacy::Shipment.where(itinerary: invalid_itineraries).update_all(itinerary_id: valid_id)
      Legacy::Trip.where(itinerary: invalid_itineraries).update_all(itinerary_id: valid_id)
      Legacy::TransitTime.where(itinerary: invalid_itineraries).update_all(itinerary_id: valid_id)
      Legacy::MapDatum.where(itinerary: invalid_itineraries).update_all(itinerary_id: valid_id)
      Legacy::MaxDimensionsBundle.where(itinerary: invalid_itineraries).update_all(itinerary_id: valid_id)
      Pricings::Margin.where(itinerary: invalid_itineraries).update_all(itinerary_id: valid_id)
      Pricings::Pricing.where(itinerary: invalid_itineraries).update_all(itinerary_id: valid_id)
      Quotations::Tender.where(itinerary: invalid_itineraries).update_all(itinerary_id: valid_id)
      Legacy::Note.where(itinerary: invalid_itineraries).update_all(itinerary_id: valid_id)
      # rubocop:enable Rails/SkipsModelValidations
      invalid_itineraries.each(&:destroy!)
    end
  end

  def duplicates
    Legacy::Itinerary.where("(select count(*) from itineraries inr where inr.origin_hub_id = itineraries.origin_hub_id AND inr.destination_hub_id = itineraries.destination_hub_id AND inr.transshipment = itineraries.transshipment AND inr.mode_of_transport = itineraries.mode_of_transport AND inr.organization_id = itineraries.organization_id) > 1")
  end
end
