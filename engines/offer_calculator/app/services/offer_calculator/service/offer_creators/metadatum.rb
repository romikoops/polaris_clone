# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class Metadatum < OfferCalculator::Service::OfferCreators::Base
        def self.metadatum(offer:, shipment:, tender:, charge_breakdown:)
          new(
            offer: offer, shipment: shipment, tender: tender, charge_breakdown: charge_breakdown
          ).perform
        end

        def initialize(offer:, shipment:, tender:, charge_breakdown:)
          @offer = offer
          @shipment = shipment
          @tender = tender
          @charge_breakdown = charge_breakdown
          super(shipment: shipment)
        end

        def perform
          charges_and_cargo.each do |charge, cargo|
            build_breakdowns_for_charge(charge: charge, cargo: cargo)
          end
        end

        private

        attr_reader :charge_breakdown, :shipment, :tender, :offer

        def charges_and_cargo
          tender.line_items.map do |line_item|
            [
              charge_for_line_item(line_item: line_item),
              line_item.cargo
            ]
          end
        end

        def metadatum
          @metadatum ||= Pricings::Metadatum.create(
            organization: shipment.organization,
            charge_breakdown_id: charge_breakdown.id
          )
        end

        def build_breakdowns_for_charge(charge:, cargo:)
          breakdowns_for_charge_and_cargo(charge: charge, cargo: cargo)
            .map.with_index do |result_breakdown, i|
            build_breakdown(
              result_breakdown: result_breakdown,
              charge: charge,
              cargo: cargo,
              index: i
            )
          end
        end

        def breakdowns_for_charge_and_cargo(charge:, cargo:)
          target_charge = offer.charges.find { |offer_charge|
            offer_charge.charge_category == charge.children_charge_category &&
              legacy_cargo_from_target(target: offer_charge.cargo) == cargo
          }
          target_charge.fee.breakdowns
        end

        def build_breakdown(result_breakdown:, charge:, cargo:, index:)
          Pricings::Breakdown.create(
            metadatum: metadatum,
            charge_id: charge.id,
            order: index,
            data: result_breakdown.data,
            charge_category_id: result_breakdown.charge_category.id,
            rate_origin: result_breakdown.metadata,
            cargo_unit: cargo,
            cargo_class: cargo&.cargo_class,
            source: result_breakdown.source,
            target: result_breakdown.target
          )
        end

        def charge_for_line_item(line_item:)
          charges.find_by(line_item_id: line_item.id)
        end

        def charges
          @charges ||= charge_breakdown.charges.where(detail_level: 3)
        end
      end
    end
  end
end
