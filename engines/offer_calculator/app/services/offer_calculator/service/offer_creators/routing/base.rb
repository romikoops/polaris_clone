# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      module Routing
        class Base
          attr_reader :request, :offer, :section

          def self.get(section:)
            case section
            when /trucking/
              OfferCalculator::Service::OfferCreators::Routing::Carriage
            when /port/
              OfferCalculator::Service::OfferCreators::Routing::Relay
            else
              OfferCalculator::Service::OfferCreators::Routing::Freight
            end
          end

          def initialize(request:, offer:, section:)
            @request = request
            @offer = offer
            @section = section
          end

          def from_route_point
            @from_route_point ||= route_point(location: from)
          end

          def to_route_point
            @to_route_point ||= route_point(location: to)
          end

          def route_section
            @route_section ||= Journey::RouteSection.new(
              from: from_route_point,
              to: to_route_point,
              mode_of_transport: mode_of_transport,
              service: tenant_vehicle.name,
              carrier: carrier_name,
              order: order,
              transit_time: transit_time
            )
          end

          def carrier_name
            legacy_carrier = tenant_vehicle.carrier
            carrier_code = tenant_vehicle.carrier.code if legacy_carrier
            carrier_code || request.organization.slug
          end

          def route_point(location:)
            name, function, locode, geo_id = case location.class.to_s
                                             when "Legacy::Hub"
                                               [location.name, "port", location.nexus.locode, geo_id_from_hub(hub: location)]
                                             when "Legacy::Address"
                                               [location.geocoded_address, "address", nil, geo_id_from_address(address: location)]
            end

            Journey::RoutePoint.create(
              name: name,
              function: function,
              locode: locode,
              coordinates: RGeo::Geos.factory(srid: 4326).point(location.longitude, location.latitude),
              geo_id: geo_id
            )
          end

          def offer_data
            @offer_data ||= offer.section(key: section)
          end

          def tenant_vehicle
            @tenant_vehicle ||= offer.tenant_vehicle(section_key: section)
          end

          def order
            @order ||= offer.section_keys.index(section)
          end

          def transit_time
            0
          end

          def geo_id_from_hub(hub:)
            Carta::Client.suggest(query: hub.nexus.locode).id
          end

          def geo_id_from_address(address:)
            request.geo_id(target: address == request.pickup_address ? "origin" : "destination")
          end
        end
      end
    end
  end
end
