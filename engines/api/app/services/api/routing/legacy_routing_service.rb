# frozen_string_literal: true

module Api
  module Routing
    class LegacyRoutingService
      def self.routes(organization:, user:, scope:, load_type:)
        new(organization: organization, user: user, scope: scope, load_type: load_type).perform
      end

      def initialize(organization:, user:, scope:, load_type:)
        @organization = organization
        @user = user
        @scope = scope
        @load_type = load_type
        @hierarchy = OrganizationManager::HierarchyService.new(organization: organization, target: user).fetch
      end

      def perform
        OfferCalculator::Route.detailed_hashes_from_itinerary_ids(
          itinerary_ids,
          load_type: load_type
        )
      end

      private

      attr_reader :organization, :hierarchy, :user, :scope, :load_type

      def itinerary_ids
        return dedicated_itineraries.ids if scope[:display_itineraries_with_rates]

        itineraries.ids
      end

      def dedicated_itineraries
        margin_itineraries.or(dedicated_pricing_itineraries)
      end

      def margins
        @margins ||= Pricings::Margin.where(applicable: margin_hierarchy, cargo_class: margin_cargo_classes)
      end

      def margin_itineraries
        itineraries
          .where(id: margins.select(:itinerary_id))
      end

      def pricings
        @pricings ||= Pricings::Pricing
          .where(organization: organization)
          .where("validity @> ?::date", Time.zone.today)
      end

      def dedicated_pricings
        pricings.where(group: hierarchy_groups)
      end

      def dedicated_pricing_itineraries
        itineraries.merge(dedicated_pricings)
      end

      def itineraries
        @itineraries ||= Legacy::Itinerary
          .where(organization: organization)
          .joins(:rates)
          .merge(pricings)
      end

      def hierarchy_groups
        @hierarchy_groups ||= hierarchy.select { |hier| hier.is_a?(Groups::Group) }
      end

      def margin_cargo_classes
        [nil] + (load_type == "cargo_item" ? ["lcl"] : Legacy::Container::CARGO_CLASSES)
      end

      def margin_hierarchy
        @margin_hierarchy ||= hierarchy.reject { |hier| hier.is_a?(Organizations::Organization) }
      end
    end
  end
end
