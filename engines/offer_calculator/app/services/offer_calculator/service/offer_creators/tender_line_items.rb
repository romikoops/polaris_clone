# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class TenderLineItems < OfferCalculator::Service::OfferCreators::Base
        def self.tender(offer:, shipment:, tender:)
          new(offer: offer, shipment: shipment, tender: tender).perform
        end

        def initialize(offer:, shipment:, tender:)
          super(shipment: shipment)
          @offer = offer
          @shipment = shipment
          @tender = tender
        end

        def perform
          tender.update(
            amount: total,
            original_amount: total
          )
          tender
        end

        private

        attr_reader :tender, :shipment, :offer

        def line_items
          @line_items ||= offer.charges.map { |charge|
            line_item_from_charge(charge: charge)
          }
        end

        def line_item_from_charge(charge:)
          line_item = ::Quotations::LineItem.create(
            charge_category: charge.charge_category,
            tender: tender,
            section: "#{charge.section}_section",
            cargo: legacy_cargo_from_target(target: charge.cargo),
            amount: charge.value,
            original_amount: charge.value
          )
          charge.line_item = line_item
          line_item
        end

        def total
          @total ||= line_items.inject(Money.new(0, currency_for_user)) { |sum, item| sum + item.amount }.round
        end
      end
    end
  end
end
