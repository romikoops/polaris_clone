# frozen_string_literal: true

module Api
  module V1
    class NoteDecorator < Draper::Decorator
      decorates "Legacy::Note"

      delegate_all

      def legacy_json
        as_json.merge(
          "itineraryTitle" => itinerary&.name,
          "mode_of_transport" => itinerary&.mode_of_transport,
          "service" => tenant_vehicle&.full_name
        ).compact
      end

      private

      def itinerary
        return Pricings::Pricing.find(pricings_pricing_id).itinerary if pricings_pricing_id.present?
        return target if target_type.match?(/Itinerary/)
      end

      def tenant_vehicle
        return Pricings::Pricing.find(pricings_pricing_id).tenant_vehicle if pricings_pricing_id.present?
      end
    end
  end
end
