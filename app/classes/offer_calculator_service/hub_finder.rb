# frozen_string_literal: true

module OfferCalculatorService
  class HubFinder < Base
    def exec(_trucking_pricings)
      { origin: "pre", destination: "on" }.reduce({}) do |hubs, (target, carriage)|
        hubs.merge(target => hubs_for_target(target, carriage))
      end
    end

    private

    def hubs_for_target(target, carriage)
      if @shipment.has_carriage?(carriage)
        Hub.where(id: trucking_pricings[carriage].map(&:preloaded_hub_id))
      else
        @shipment.tenant.hubs.where(nexus_id: @shipment["#{target}_nexus_id"])
      end
    end
  end
end
