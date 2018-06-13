# frozen_string_literal: true

module OfferCalculatorService
  class TruckingDataBuilder < Base
    def exec(hubs)
      { origin: "pre", destination: "on" }
        .select { |_, carriage| @shipment.has_carriage?(carriage) }
        .each_with_object({}) do |(target, carriage), obj|
          obj[carriage] = data_for_hubs(hubs[target], carriage)
        end
    end

    private

    def data_for_hubs(hub_ids, carriage)
      trucking_details = @shipment.trucking["#{carriage}_carriage"]
      address          = Location.find(trucking_details["location_id"])

      trucking_pricing_finder = TruckingPricingFinder.new(
        trucking_details: trucking_details,
        address:          address,
        carriage:         carriage,
        shipment:         @shipment
      )

      Hub.where(id: hub_ids).each_with_object({}) do |hub, obj|
        distance = calc_distance(address, hub)
        obj[hub.id] = {
          trucking_pricings: trucking_pricing_finder.exec(hub.id, distance),
          distance:          distance
        }
      end
    end

    def calc_distance(address, hub)
      GoogleDirections.new(
        address.lat_lng_string,
        hub.lat_lng_string,
        @shipment.planned_pickup_date.to_i
      ).distance_in_km
    end
  end
end
