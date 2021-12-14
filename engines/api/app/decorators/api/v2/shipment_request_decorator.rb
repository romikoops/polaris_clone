# frozen_string_literal: true

module Api
  module V2
    class ShipmentRequestDecorator < ResultFormatter::ShipmentRequestDecorator
      delegate_all
      decorates_association :result, with: ResultDecorator

      delegate :query, :imc_reference, :mode_of_transport, to: :result

      def status
        super.humanize
      end

      def origin_hub
        result.origin_route_point.name
      end

      def destination_hub
        result.destination_route_point.name
      end

      def origin_pickup
        return if result.pre_carriage_section.blank?

        result.pre_carriage_section.from.name
      end

      def destination_dropoff
        return if result.on_carriage_section.blank?

        result.on_carriage_section.to.name
      end
    end
  end
end
