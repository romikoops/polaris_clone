# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      module Routing
        class LocationAsRoutePoint
          def initialize(location:, request:)
            @location = location
            @request = request
          end

          attr_reader :location, :request

          delegate :latitude, :longitude, to: :location

          def perform
            Journey::RoutePoint.create!(
              name: name,
              function: function,
              terminal: terminal,
              locode: locode,
              country: country_code,
              coordinates: RGeo::Geos.factory(srid: 4326).point(location.longitude, location.latitude),
              geo_id: geo_id
            )
          end

          private

          def hub?
            @hub ||= location.is_a?(Legacy::Hub)
          end

          def wrapped_location
            @wrapped_location ||= if hub?
              WrappedHub.new(hub: location)
            else
              WrappedAddress.new(address: location, request: request)
            end
          end

          delegate :name, :function, :locode, :terminal, :geo_id, :country_code, to: :wrapped_location

          class WrappedAddress
            def initialize(address:, request:)
              @address = address
              @request = request
            end

            attr_reader :address, :request

            def name
              address.geocoded_address
            end

            def function
              "address"
            end

            def locode
              nil
            end

            def terminal
              nil
            end

            def country_code
              address.country&.code
            end

            def geo_id
              address == request.pickup_address ? request.origin_geo_id : request.destination_geo_id
            end
          end

          class WrappedHub
            def initialize(hub:)
              @hub = hub
            end

            attr_reader :hub

            delegate :name, :terminal, :nexus, to: :hub

            def function
              "port"
            end

            def locode
              nexus.locode
            end

            def country_code
              nexus.country.code
            end

            def geo_id
              Carta::Client.suggest(query: nexus.locode).id
            rescue Carta::Client::ServiceUnavailable
              raise OfferCalculator::Errors::OfferBuilder
            rescue Carta::Client::LocationNotFound
              raise OfferCalculator::Errors::LocationNotFound
            end
          end
        end
      end
    end
  end
end
