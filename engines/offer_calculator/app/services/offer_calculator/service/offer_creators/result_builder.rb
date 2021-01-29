# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class ResultBuilder
        attr_reader :request, :offers

        def self.results(request:, offers:)
          new(request: request, offers: offers).perform
        end

        def initialize(request:, offers:)
          @request = request
          @offers = offers
        end

        def perform
          offers.each do |offer|
            result = build_journey_data(offer: offer)
            build_metadata(result: result, offer: offer)
          end
          result_set
        end

        private

        delegate :query, :result_set, to: :request

        def build_journey_data(offer:)
          line_item_set = Journey::LineItemSet.create(result: result_from_offer(offer: offer))
          offer.section_keys.each do |section|
            build_section_data(offer: offer, section: section, line_item_set: line_item_set)
          end
          line_item_set.result
        end

        def result_from_offer(offer:)
          Journey::Result.create(
            result_set: result_set,
            issued_at: Time.zone.now,
            expiration_date: offer.valid_until
          )
        end

        def build_section_data(offer:, section:, line_item_set:)
          OfferCalculator::Service::OfferCreators::SectionBuilder.new(
            line_item_set: line_item_set,
            offer: offer,
            section: section,
            request: request
          ).perform
        end

        def route_points(offer:)
          itinerary = offer.itinerary
          [
            request.pickup_address,
            itinerary.origin_hub,
            itinerary.destination_hub,
            request.delivery_address
          ].compact.map do |location|
            routepoint(location: location)
          end
        end

        def route_point(location:)
          name, function = case location.class
          when Legacy::Hub
            [location.name, "port"]
          when Legacy::Address
            [location.geocoded_address, "address"]
          end

          Journey::RoutePoint.find_or_create_by(
            name: name,
            function: function,
            coordinates: location.point
          )
        end

        def build_metadata(offer:, result:)
          OfferCalculator::Service::OfferCreators::Metadatum.metadatum(offer: offer, result: result)
        end
      end
    end
  end
end
