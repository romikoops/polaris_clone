# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class LineItemSetBuilder
        attr_reader :request, :offer, :route_sections

        def self.line_item_set(request:, offer:, route_sections:)
          new(request: request, offer: offer, route_sections: route_sections).line_item_set
        end

        def initialize(request:, offer:, route_sections:)
          @request = request
          @offer = offer
          @route_sections = route_sections
        end

        def line_item_set
          Journey::LineItemSet.new(
            line_items: line_items
          )
        end

        private

        def line_items
          LineItemBuilder.line_items(offer: offer, request: request, route_sections: route_sections)
        end
      end
    end
  end
end
