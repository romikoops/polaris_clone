# frozen_string_literal: true

module Api
  module V2
    class RoutePointDecorator < ResultFormatter::RoutePointDecorator
      decorates "Journey::RoutePoint"

      delegate_all

      def latitude
        coordinates.y
      end

      def longitude
        coordinates.x
      end

      def country
        @country ||= super || Legacy::Address.new(
          latitude: coordinates.y, longitude: coordinates.x
        ).reverse_geocode.country&.code
      end
    end
  end
end
