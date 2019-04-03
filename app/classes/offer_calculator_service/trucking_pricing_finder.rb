# frozen_string_literal: true

module OfferCalculatorService
  class TruckingPricingFinder < Base
    def initialize(args = {})
      @address          = args[:address]
      @trucking_details = args[:trucking_details]
      @carriage         = args[:carriage]
      @user_id = args[:user_id]
      super(args[:shipment])
    end

    def perform(hub_id, distance)
      args = {
        address: @address,
        load_type: @shipment.load_type,
        tenant_id: @shipment.tenant_id,
        truck_type: @trucking_details['truck_type'],
        cargo_classes: @shipment.cargo_classes,
        carriage: @carriage,
        hub_ids: [hub_id],
        distance: distance.round
      }
      results = Trucking::Queries::Availability.new(args).perform | Trucking::Queries::Distance.new(args).perform
      binding.pry if results.empty?
      return [] if results.empty?

      truckings = @shipment.cargo_classes.each_with_object({}) { |cargo_class, h| h[cargo_class] = nil }
      results.group_by(&:cargo_class)
             .each do |cargo_class, truckings_by_cargo_class|
        trucking = truckings_by_cargo_class.select { |r| r.user_id == @user_id || r.user_id.nil? }
                                           .sort_by { |r| r.user_id || 0 }
                                           .reverse
                                           .first
        truckings[cargo_class] = trucking
      end

      truckings
    end
  end
end
