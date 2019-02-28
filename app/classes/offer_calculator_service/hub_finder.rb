# frozen_string_literal: true

module OfferCalculatorService
  class HubFinder < Base
    def perform
      binding.pry
      { origin: 'pre', destination: 'on' }.reduce({}) do |hubs, (target, carriage)|
        hubs.merge(target => hubs_for_target(target, carriage))
      end
    end

    private

    def hubs_for_target(target, carriage)
      if @shipment.has_carriage?(carriage)
        Hub.where(id: trucking_hub_ids(carriage))
      else
        @shipment.tenant.hubs.where(nexus_id: @shipment["#{target}_nexus_id"])
      end
    end

    def trucking_hub_ids(carriage)
      trucking_details = @shipment.trucking["#{carriage}_carriage"]
      TruckingPricing.find_by_filter(
        address: Address.find(trucking_details['address_id']),
        load_type: @shipment.load_type,
        tenant_id: @shipment.tenant_id,
        truck_type: trucking_details['truck_type'],
        carriage: carriage
      ).pluck(:hub_id)
    end
  end
end
