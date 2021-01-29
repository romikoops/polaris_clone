# frozen_string_literal: true

module Api
  module V2
    class RoutePointDecorator < Draper::Decorator
      decorates "Journey::RoutePoint"

      delegate_all

      def latitude
        coordinates.y
      end

      def longitude
        coordinates.x
      end

      def description
        name
      end

      def country
        @country ||= Legacy::Address.new(
          latitude: coordinates.y, longitude: coordinates.x
        ).reverse_geocode.country.code
      end
    end
  end
end
