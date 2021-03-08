# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class SectionBuilder
        attr_reader :line_item_set, :offer, :section, :request

        delegate :result, to: :line_item_set
        delegate :cargo_units, to: :query

        def initialize(line_item_set:, offer:, section:, request:)
          @line_item_set = line_item_set
          @offer = offer
          @section = section
          @request = request
        end

        def perform
          offer.section(key: section).map do |charge|
            cargo_connections(line_item: line_item_from_charge(charge: charge), charge: charge)
          end
        end

        private

        def query
          @query ||= result.result_set.query
        end

        def section_route_data
          @section_route_data ||= OfferCalculator::Service::OfferCreators::Routing::Base.get(section: section).new(
            request: request, result: result, offer: offer, section: section
          )
        end

        delegate :route_section, :to_route_point, :from_route_point, to: :section_route_data

        def line_item_from_charge(charge:)
          code = code_from_charge(charge: charge)
          Journey::LineItem.new(
            route_section: route_section,
            route_point: from_route_point,
            total: charge.value,
            unit_price: charge.value / charge.quantity,
            units: charge.quantity,
            line_item_set: line_item_set,
            fee_code: code,
            wm_rate: charge.wm_rate,
            order: order,
            description: charge.name,
            included: code.include?("included"),
            optional: code.include?("unknown")
          ).tap do |new_line_item|
            charge.line_item = new_line_item
          end
        end

        def code_from_charge(charge:)
          charge.code.sub("included_", "").sub("unknown_", "")
        end

        def cargo_connections(line_item:, charge:)
          charge.targets.map do |cargo_unit|
            cargo_connection(line_item: line_item, cargo: cargo_unit)
          end
        end

        def cargo_connection(line_item:, cargo:)
          Journey::LineItemCargoUnit.new(
            line_item: line_item,
            cargo_unit: cargo
          )
        end

        def order
          @order ||= offer.section_keys.index(section)
        end
      end
    end
  end
end
