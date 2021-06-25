# frozen_string_literal: true

class ProperlyDedupeItinerariesWorker < DedupeItinerariesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def duplicates
    Legacy::Itinerary.where("(select count(*) from itineraries inr where inr.origin_hub_id = itineraries.origin_hub_id AND inr.destination_hub_id = itineraries.destination_hub_id AND inr.transshipment IS NULL AND itineraries.transshipment IS NULL AND inr.mode_of_transport = itineraries.mode_of_transport AND inr.organization_id = itineraries.organization_id) > 1")
  end
end
