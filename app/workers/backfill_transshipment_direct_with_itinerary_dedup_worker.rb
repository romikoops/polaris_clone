# frozen_string_literal: true

class BackfillTransshipmentDirectWithItineraryDedupWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  UNSUPPORTED_TYPES = %w[direct direkt].freeze
  MODELS_WHICH_NEED_UPDATE = [
    Legacy::Shipment,
    Legacy::Trip,
    Legacy::TransitTime,
    Legacy::MapDatum,
    Legacy::MaxDimensionsBundle,
    Pricings::Margin,
    Quotations::Tender,
    Legacy::Note
  ].freeze

  FailedTransshipmentBackFill = Class.new(StandardError)

  def perform
    target_itineraries = itinerary_direct_transshipment
    total_itineraries = target_itineraries.count
    total target_itineraries

    ActiveRecord::Base.transaction do
      target_itineraries.find_each.with_index do |itinerary, index|
        at (index + 1), "De-duping #{itinerary.name} - #{index + 1}/#{total_itineraries}"

        nil_transshipment_itinerary = itinerary_with_transshipment_nil(itinerary: itinerary)
        itinerary.update!(transshipment: nil) and next if nil_transshipment_itinerary.blank?

        update_direct_itinerary_attributes_with_nil_itinerary(nil_itinerary_id: nil_transshipment_itinerary.id, itinerary_with_direct: itinerary)
        itinerary.destroy!
      end
    end

    raise FailedTransshipmentBackFill if unsupported_type_exist?
  end

  private

  def update_direct_itinerary_attributes_with_nil_itinerary(nil_itinerary_id:, itinerary_with_direct:)
    MODELS_WHICH_NEED_UPDATE.each do |model|
      records_with_direct_transshipment_itinerary = model.where(itinerary_id: itinerary_with_direct.id)
      next unless records_with_direct_transshipment_itinerary.count.positive?

      records_with_direct_transshipment_itinerary.each do |record_with_direct_shipment_itinerary|
        record_with_direct_shipment_itinerary.itinerary_id = nil_itinerary_id
        record_with_direct_shipment_itinerary.save! if record_with_direct_shipment_itinerary.valid?
      end
    end
  end

  def unsupported_type_exist?
    return true if Legacy::Itinerary.where("LOWER(transshipment) IN (?)", UNSUPPORTED_TYPES).count.positive?

    false
  end

  def itinerary_with_transshipment_nil(itinerary:)
    Legacy::Itinerary.find_by(
      origin_hub_id: itinerary.origin_hub_id,
      destination_hub_id: itinerary.destination_hub_id,
      mode_of_transport: itinerary.mode_of_transport,
      transshipment: nil,
      organization_id: itinerary.organization_id
    )
  end

  def itinerary_direct_transshipment
    Legacy::Itinerary.where("LOWER(transshipment) IN (?)", UNSUPPORTED_TYPES)
  end
end
