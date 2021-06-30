# frozen_string_literal: true

class DedupeHubFromInserterErrorWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  FailedDeduping = Class.new(StandardError)

  def perform
    invalid_hubs = Legacy::Hub.where(terminal: "NaN", terminal_code: "NaN")
    total invalid_hubs.length

    invalid_hubs.each_with_index do |invalid_hub, index|
      valid_hub = Legacy::Hub.find_by(name: invalid_hub.name, hub_type: invalid_hub.hub_type, organization_id: invalid_hub.organization_id, terminal: nil, terminal_code: nil)
      ActiveRecord::Base.transaction do
        if valid_hub
          # rubocop:disable Rails/SkipsModelValidations
          Legacy::Stop.where(hub: invalid_hub).update_all(hub_id: valid_hub.id)
          Legacy::Itinerary.where(origin_hub: invalid_hub).update_all(origin_hub_id: valid_hub.id)
          Legacy::Itinerary.where(destination_hub: invalid_hub).update_all(destination_hub_id: valid_hub.id)
          Legacy::Shipment.where(origin_hub: invalid_hub).update_all(origin_hub_id: valid_hub.id)
          Legacy::Shipment.where(destination_hub: invalid_hub).update_all(destination_hub_id: valid_hub.id)
          Legacy::Shipment.where(origin_nexus: invalid_hub.nexus).update_all(origin_nexus_id: valid_hub.nexus_id)
          Legacy::Shipment.where(destination_nexus: invalid_hub.nexus).update_all(destination_nexus_id: valid_hub.nexus_id)
          Pricings::Margin.where(origin_hub: invalid_hub).update_all(origin_hub_id: valid_hub.id)
          Pricings::Margin.where(destination_hub: invalid_hub).update_all(destination_hub_id: valid_hub.id)
          Legacy::LocalCharge.where(hub: invalid_hub).update_all(hub_id: valid_hub.id)
          Legacy::LocalCharge.where(counterpart_hub: invalid_hub).update_all(counterpart_hub_id: valid_hub.id)
          Legacy::Note.where(hub: invalid_hub).update_all(hub_id: valid_hub.id)
          Trucking::Trucking.where(hub: invalid_hub).update_all(hub_id: valid_hub.id)
          # rubocop:enable Rails/SkipsModelValidations
          invalid_hub.destroy!
        else
          invalid_hub.update(terminal: nil, terminal_code: nil)
        end
      end
      at index + 1, "Hub #{[invalid_hub.name, invalid_hub.hub_code].join(' - ')} #{index + 1} / #{invalid_hubs.length} done"
    end

    raise FailedDeduping unless Legacy::Hub.where(terminal: "NaN", terminal_code: "NaN").empty?
  end
end
