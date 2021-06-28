# frozen_string_literal: true

class BackfillUpsertIdOnItineraryWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE itineraries
        SET upsert_id = uuid_generate_v5('#{Legacy::Itinerary::UUID_V5_NAMESPACE}', CONCAT(origin_hub_id::text, destination_hub_id::text, organization_id::text, transshipment::text, mode_of_transport::text)::text)
      SQL
    )
  end
end
