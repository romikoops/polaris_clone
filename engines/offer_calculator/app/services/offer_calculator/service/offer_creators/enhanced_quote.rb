# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class EnhancedQuote < OfferCalculator::Service::OfferCreators::Base
        def self.quote(charge_breakdown:, offer:, scope:)
          new(
            charge_breakdown: charge_breakdown,
            offer: offer,
            scope: scope
          ).perform
        end

        def initialize(charge_breakdown:, offer:, scope:)
          @charge_breakdown = charge_breakdown
          @tender = charge_breakdown.tender
          @offer = offer
          @scope = scope
          super(shipment: charge_breakdown.shipment)
        end

        def perform
          recursive_result_builder(charge: charge_breakdown.grand_total)
        end

        private

        attr_reader :offer, :charge_breakdown, :meta, :scope, :tender

        def recursive_result_builder(charge:, sub_total_charge: false)
          return final_attributes(charge: charge) if charge.children.empty?

          children_charges = charge.children.map { |child_charge|
            children_charge_category = child_charge.children_charge_category
            key = children_charge_category.try(:cargo_unit_id) || children_charge_category.code.downcase
            [
              key,
              recursive_result_builder(charge: child_charge, sub_total_charge: true)
            ]
          }

          {
            total: total(charge: charge, sub_total_charge: sub_total_charge),
            edited_total: charge.edited_price.try(:rounded_attributes),
            name: charge.children_charge_category.name
          }.merge(children_charges.to_h)
        end

        def should_hide(charge:, sub_total_charge:)
          should_hide_grand_total(charge: charge) || (guest? || (hidden_sub_total && sub_total_charge))
        end

        def total(charge:, sub_total_charge:)
          return if should_hide(charge: charge, sub_total_charge: sub_total_charge)

          charge.edited_price.try(:rounded_attributes) || charge.price.rounded_attributes
        end

        def should_hide_grand_total(charge:)
          charge.charge_category.code == "base_node" && ((hidden_grand_total || guest?) ||
            (hide_converted_grand_total && charge.charge_breakdown.currency_count > 1))
        end

        def hidden_grand_total
          scope.fetch(:hide_grand_total, false)
        end

        def hidden_sub_total
          scope.fetch(:hide_sub_totals, false)
        end

        def hide_converted_grand_total
          scope.fetch(:hide_converted_grand_total, false)
        end

        def guest?
          charge_breakdown.shipment.user.nil?
        end

        def final_attributes(charge:)
          price_to_return = charge.edited_price || charge.price
          price_to_return
            .given_attributes
            .merge(name: charge.children_charge_category.name)
            .merge(rate_info(charge: charge))
        end

        def rate_info(charge:)
          offer_charge = applicable_offer_charge(charge: charge)

          {
            rate: money_attributes(money: offer_charge.rate),
            min_value: money_attributes(money: offer_charge.min_value)
          }
        end

        def money_attributes(money:)
          {
            value: money.amount,
            currency: money.currency.iso_code
          }
        end

        def applicable_offer_charge(charge:)
          offer.charges.find do |offer_charge|
            section_matches(charge: charge, offer_charge: offer_charge) &&
              charge_category_matches(charge: charge, offer_charge: offer_charge) &&
              cargo_matches(charge: charge, offer_charge: offer_charge)
          end
        end

        def section_matches(charge:, offer_charge:)
          offer_charge.section == charge.parent.charge_category.code
        end

        def charge_category_matches(charge:, offer_charge:)
          offer_charge.charge_category == charge.children_charge_category
        end

        def cargo_matches(charge:, offer_charge:)
          (offer_charge.section.include?("trucking") ||
          legacy_cargo_from_target(target: offer_charge.cargo)&.id == charge.charge_category.cargo_unit_id)
        end
      end
    end
  end
end
