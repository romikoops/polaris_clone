# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class LineItems < OfferCalculator::Service::OfferCreators::Base
        def self.line_items(offer:, shipment:, tender:)
          new(offer: offer, shipment: shipment, tender: tender).perform
        end

        def initialize(offer:, shipment:, tender:)
          super(shipment: shipment)
          @offer = offer
          @shipment = shipment
          @tender = tender
        end

        def perform
          offer.charges.map do |charge|
            line_item = ::Quotations::LineItem.create(
              charge_category: charge.charge_category,
              tender: tender,
              section: "#{charge.section}_section",
              cargo: legacy_cargo_from_target(target: charge.cargo),
              amount: charge.value,
              original_amount: charge.value
            )
            charge.line_item = line_item
          end
        end

        private

        attr_reader :tender, :shipment, :offer
      end
    end
  end
end
