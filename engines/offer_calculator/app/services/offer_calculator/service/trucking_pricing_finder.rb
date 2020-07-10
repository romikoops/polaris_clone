# frozen_string_literal: true

module OfferCalculator
  module Service
    class TruckingPricingFinder < Base
      def initialize(args = {})
        @address          = args.fetch(:address)
        @trucking_details = args.fetch(:trucking_details)
        @carriage         = args.fetch(:carriage)
        @sandbox          = args.fetch(:sandbox)
        @shipment         = args.fetch(:shipment)
        @user = Users::User.find(args[:user_id]) if args[:user_id]
        super(shipment: @shipment, sandbox: @sandbox)
      end

      def perform(hub_id, distance) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
        args = {
          address: @address,
          load_type: @shipment.load_type,
          organization_id: @shipment.organization_id,
          truck_type: @trucking_details['truck_type'],
          cargo_classes: @shipment.cargo_classes,
          carriage: @carriage,
          hub_ids: [hub_id],
          distance: distance.round,
          sandbox: @sandbox,
          order_by: 'group_id'
        }

        results = Trucking::Queries::Availability.new(args).perform

        return [] if results.empty?

        truckings = @shipment.cargo_classes.each_with_object({}) { |cargo_class, h| h[cargo_class] = nil }
        grouped_results = results.group_by(&:cargo_class)
        group_ids = user_groups&.reverse || []
        group_ids.unshift(nil)
        group_ids.each do |group_id|
          grouped_results.each do |cargo_class, truckings_by_cargo_class|
            trucking = truckings_by_cargo_class.find { |trp| trp.user_id.nil? && group_id == trp.group_id }
            truckings[cargo_class] = trucking if trucking.present?
          end
        end

        truckings
      end

      def user_groups
        OrganizationManager::HierarchyService.new(target: @user, organization: organization)
          .fetch
          .select { |target| target.is_a?(Groups::Group) }
          .pluck(:id)
      end
    end
  end
end
