# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class LineItemBuilder
        attr_reader :line_item_set, :offer, :route_sections, :request

        delegate :result, to: :line_item_set
        delegate :cargo_units, to: :query

        def self.line_items(offer:, request:, route_sections:)
          new(offer: offer, request: request, route_sections: route_sections).line_items
        end

        def initialize(offer:, request:, route_sections:)
          @offer = offer
          @route_sections = route_sections
          @request = request
        end

        def line_items
          offer.sections.flat_map.with_index do |charges, index|
            charges.map do |charge|
              line_item_from_charge(charge: charge, order: index)
            end
          end
        end

        private

        def query
          @query ||= result.result_set.query
        end

        def line_item_from_charge(charge:, order:)
          route_section = route_sections[order]
          Journey::LineItem.new(
            route_section: route_section,
            route_point: route_section.from,
            total: charge.value,
            unit_price: charge.value / charge.quantity,
            units: charge.quantity,
            line_item_set: line_item_set,
            fee_code: charge.code.sub(/\A(included_|unknown_)/, ""),
            wm_rate: charge.wm_rate,
            order: order,
            description: charge.name,
            included: charge.code.include?("included"),
            optional: charge.code.include?("unknown"),
            cargo_units: charge.targets
          ).tap do |new_line_item|
            charge.line_item = new_line_item
          end
        end
      end
    end
  end
end
