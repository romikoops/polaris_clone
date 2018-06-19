# frozen_string_literal: true

module OfferCalculatorService
  class TruckingDataBuilder < Base
    include TruckingTools

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
        trucking_pricings = trucking_pricing_finder.exec(hub.id, distance)

        trucking_charge_data = data_for_trucking_charges(trucking_pricings, distance)
        obj[hub.id] = { trucking_charge_data: trucking_charge_data }
      end
    end

    def calc_distance(address, hub)
      GoogleDirections.new(
        address.lat_lng_string,
        hub.lat_lng_string,
        @shipment.planned_pickup_date.to_i
      ).distance_in_km
    end

    def data_for_trucking_charges(trucking_pricings, distance)
      trucking_pricings.each_with_object({}) do |trucking_pricing, trucking_charge_data|
        key = trucking_pricing.cargo_class
        trucking_charges = calc_trucking_charges(distance, trucking_pricing)
        next if trucking_charges.nil?

        trucking_charge_data[key] = trucking_charges
      end
    end

    def calc_trucking_charges(distance, trucking_pricing)
      cargo_class = trucking_pricing.cargo_class
      cargo_units = @shipment.cargo_units.where(cargo_class: cargo_class)
      return nil if cargo_units.empty?

      calc_trucking_price(
        trucking_pricing,
        cargo_units,
        distance,
        trucking_pricing.carriage
      )
    end
  end
end
