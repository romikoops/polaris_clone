# frozen_string_literal: true

module OfferCalculatorService
  class TruckingPricingFinder < Base
    def initialize(shipment)
      @shipment = shipment
    end

    def exec
      %w(pre on)
        .select { |carriage| @shipment.has_carriage?(carriage) }
        .map { |carriage| [carriage, trucking_pricings(carriage)] }.to_h
    end

    private

    def trucking_pricings(carriage, address=nil)
      trucking_details = @shipment.trucking["#{carriage}_carriage"]
      TruckingPricing.find_by_filter(
        location:   address || Location.find(trucking_details["location_id"]),
        load_type:  @shipment.load_type,
        tenant_id:  @shipment.tenant_id,
        truck_type: trucking_details["truck_type"],
        carriage:   carriage
      )
    end
  end
end
