# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class RouteSectionBuilder
        attr_reader :offer, :request


        def self.route_sections(request:, offer:)
          new(request: request, offer: offer).route_sections
        end

        def initialize(offer:, request:)
          @offer = offer
          @request = request
        end

        def route_sections
          offer.section_keys.map do |section|
            OfferCalculator::Service::OfferCreators::Routing::Base.get(section: section).new(
              request: request, offer: offer, section: section
            ).route_section
          end
        end
      end
    end
  end
end
