# frozen_string_literal: true

module OfferCalculatorService
  class TruckingPricingFinder < Base
    def initialize(args = {})
      @address          = args[:address]
      @trucking_details = args[:trucking_details]
      @carriage         = args[:carriage]
      super(args[:shipment])
    end

    def perform(hub_id, distance)
      args = {
        address: @address,
        load_type: @shipment.load_type,
        tenant_id: @shipment.tenant_id,
        truck_type: @trucking_details['truck_type'],
        carriage: @carriage,
        hub_ids: [hub_id],
        distance: distance.round
      }

      Trucking::Rate.find_by_filter(args)
    end
  end
end
