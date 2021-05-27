# frozen_string_literal: true

class CleanHubsTableWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  FailedDeduping = Class.new(StandardError)

  def perform
    # Two hubs are causing issues on porting the trucking data - DEMO: Shanghai and IFBHAMBURG: Bremen. As both are non essential removing them prior to deduping
    problematic_hubs = [
      Legacy::Hub.where(name: "Shanghai", organization: Organizations::Organization.find_by(slug: "demo")),
      Legacy::Hub.where(name: "Bremen", organization: Organizations::Organization.find_by(slug: "ifbhamburg"))
    ].flatten
    Trucking::Trucking.where(hub: problematic_hubs).destroy_all

    # Now we can proceed and if an error is raised there is a real issue

    duplicates = Legacy::Hub.where("(select count(*) from hubs inr where inr.name = hubs.name AND inr.hub_type = hubs.hub_type AND inr.organization_id = hubs.organization_id) > 1")
    name_organization_pairs = duplicates.select(:name, :hub_type, :organization_id).distinct
    total name_organization_pairs.length

    name_organization_pairs.each_with_index do |record, index|
      hubs = Legacy::Hub.where(name: record.name, hub_type: record.hub_type, organization_id: record.organization_id).sort_by { |hub| -Legacy::Itinerary.where(origin_hub: hub).or(Legacy::Itinerary.where(destination_hub: hub)).count }
      valid_hub = hubs.shift
      invalid_hubs = hubs
      ActiveRecord::Base.transaction do
        # rubocop:disable Rails/SkipsModelValidations
        Legacy::Stop.where(hub: invalid_hubs).update_all(hub_id: valid_hub.id)
        Legacy::Itinerary.where(origin_hub: invalid_hubs).update_all(origin_hub_id: valid_hub.id)
        Legacy::Itinerary.where(destination_hub: invalid_hubs).update_all(destination_hub_id: valid_hub.id)
        Legacy::Shipment.where(origin_hub: invalid_hubs).update_all(origin_hub_id: valid_hub.id)
        Legacy::Shipment.where(destination_hub: invalid_hubs).update_all(destination_hub_id: valid_hub.id)
        Legacy::Shipment.where(origin_nexus: invalid_hubs.map(&:nexus)).update_all(origin_nexus_id: valid_hub.nexus_id)
        Legacy::Shipment.where(destination_nexus: invalid_hubs.map(&:nexus)).update_all(destination_nexus_id: valid_hub.nexus_id)
        Pricings::Margin.where(origin_hub: invalid_hubs).update_all(origin_hub_id: valid_hub.id)
        Pricings::Margin.where(destination_hub: invalid_hubs).update_all(destination_hub_id: valid_hub.id)
        Quotations::Tender.where(origin_hub: invalid_hubs).update_all(origin_hub_id: valid_hub.id)
        Quotations::Tender.where(destination_hub: invalid_hubs).update_all(destination_hub_id: valid_hub.id)
        Quotations::Quotation.where(origin_nexus: invalid_hubs.map(&:nexus)).update_all(origin_nexus_id: valid_hub.nexus_id)
        Quotations::Quotation.where(destination_nexus: invalid_hubs.map(&:nexus)).update_all(destination_nexus_id: valid_hub.nexus_id)
        Legacy::LocalCharge.where(hub: invalid_hubs).update_all(hub_id: valid_hub.id)
        Legacy::LocalCharge.where(counterpart_hub: invalid_hubs).update_all(counterpart_hub_id: valid_hub.id)
        Legacy::Note.where(hub: invalid_hubs).update_all(hub_id: valid_hub.id)
        invalid_hubs.each do |invalid_hub|
          Trucking::Trucking.where(hub: invalid_hub).update_all(hub_id: valid_hub.id)
        end
        ::CustomsFee.where(hub: invalid_hubs).update_all(hub_id: valid_hub.id)
        ::CustomsFee.where(counterpart_hub_id: invalid_hubs).update_all(counterpart_hub_id: valid_hub.id)
        # rubocop:enable Rails/SkipsModelValidations
        invalid_hubs.each(&:destroy!)
      end
      at index + 1, "Hub #{[valid_hub.name, valid_hub.hub_code].join(' - ')} #{index + 1} / #{name_organization_pairs.length} done"
    end

    raise FailedDeduping unless Legacy::Hub.where("(select count(*) from hubs inr where inr.name = hubs.name AND inr.hub_type = hubs.hub_type AND inr.organization_id = hubs.organization_id) > 1").count.zero?
  end
end
