# frozen_string_literal: true

module Api
  module V2
    class RouteSectionDecorator < Draper::Decorator
      decorates "Journey::RouteSection"
      decorates_association :result, with: Api::V2::ResultDecorator
      delegate_all

      delegate :transshipment, to: :result

      def origin
        route_point_info(route_point: from)
      end

      def destination
        route_point_info(route_point: to)
      end

      def carrier_logo
        @carrier_logo ||= logo.attached? ? Rails.application.routes.url_helpers.rails_blob_url(logo) : nil
      end

      private

      def route_point_info(route_point:)
        route_point.slice(:name, :locode, :city, :coordinates).tap do |data|
          data[:address] = data.delete(:name)
        end
      end

      def routing_carrier
        ::Routing::Carrier.find_by(name: carrier)
      end

      delegate :logo, to: :routing_carrier
    end
  end
end
