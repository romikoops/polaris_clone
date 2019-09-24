# frozen_string_literal: true

module OfferCalculatorService
  class TruckingPricingFinder < Base
    def initialize(args = {})
      @address          = args.fetch(:address)
      @trucking_details = args.fetch(:trucking_details)
      @carriage         = args.fetch(:carriage)
      @sandbox          = args.fetch(:sandbox)
      @shipment         = args.fetch(:shipment)
      @user = User.find(args[:user_id]) if args[:user_id]
      super(shipment: @shipment, sandbox: @sandbox)
    end

    def perform(hub_id, distance) # rubocp:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Meetrics/MethodLength
      args = {
        address: @address,
        load_type: @shipment.load_type,
        tenant_id: @shipment.tenant_id,
        truck_type: @trucking_details['truck_type'],
        cargo_classes: @shipment.cargo_classes,
        carriage: @carriage,
        hub_ids: [hub_id],
        distance: distance.round,
        sandbox: @sandbox
      }

      results = Trucking::Queries::Availability.new(args).perform | Trucking::Queries::Distance.new(args).perform
      return [] if results.empty?

      truckings = @shipment.cargo_classes.each_with_object({}) { |cargo_class, h| h[cargo_class] = nil }
      grouped_results = results.group_by(&:cargo_class)
      if @scope['base_pricing']
        group_ids = @user&.all_groups&.ids || []
        group_ids.unshift(nil)
        group_ids.each do |group_id|
          grouped_results.each do |cargo_class, truckings_by_cargo_class|
            trucking = truckings_by_cargo_class
                       .select { |trp| trp.user_id.nil? && [group_id, nil].include?(trp.group_id) }
                       .max_by { |trp| trp.group_id.to_i }
            truckings[cargo_class] = trucking if trucking
          end
        end
      else
        results.group_by(&:cargo_class)
               .each do |cargo_class, truckings_by_cargo_class|
          trucking = truckings_by_cargo_class
                        .select { |trp| trp.group_id.nil? && [@user&.id, nil].include?(trp.user_id) }
                        .max_by { |trp| trp.user_id.to_i }

          truckings[cargo_class] = trucking if trucking
        end
      end

      truckings
    end
  end
end
