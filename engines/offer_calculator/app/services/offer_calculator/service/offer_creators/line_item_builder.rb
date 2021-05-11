# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class LineItemBuilder
        attr_reader :line_item_set, :offer, :route_sections, :request

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

        def result_set
          @result_set ||= request.result_set
        end

        def currency
          result_set.currency
        end

        def cargo_units
          result_set.query.cargo_units
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
            chargeable_density: charge.chargeable_density,
            order: order,
            description: charge.name,
            included: charge.code.include?("included"),
            optional: charge.code.include?("unknown"),
            cargo_units: charge.targets,
            exchange_rate: exchange_rate(from: charge.value.currency.iso_code, to: currency)
          ).tap do |new_line_item|
            charge.line_item = new_line_item
          end
        end

        def exchange_rate(from:, to:)
          return 1 if from == to

          Money.default_bank.get_rate(from, to)
        end
      end
    end
  end
end
