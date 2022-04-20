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
            @from_route_point ||= OfferCalculator::Service::OfferCreators::Routing::LocationAsRoutePoint.new(
              location: from, request: request
            ).perform
          end

          def to_route_point
            @to_route_point ||= OfferCalculator::Service::OfferCreators::Routing::LocationAsRoutePoint.new(
              location: to, request: request
            ).perform
          end

          def route_section
            @route_section ||= Journey::RouteSection.new(
              from: from_route_point,
              to: to_route_point,
              mode_of_transport: mode_of_transport,
              service: tenant_vehicle.name,
              carrier: carrier_name,
              order: order,
              transit_time: transit_time,
              transshipment: transshipment
            )
          end

          def carrier_name
            legacy_carrier = tenant_vehicle.carrier
            carrier_code = legacy_carrier ? legacy_carrier.code : request.organization.slug

            routing_carrier = ::Routing::Carrier.find_by(code: carrier_code)
            raise OfferCalculator::Errors::OfferBuilder if routing_carrier.nil?

            routing_carrier.name
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

          def transshipment
            nil
          end
        end
      end
    end
  end
end
