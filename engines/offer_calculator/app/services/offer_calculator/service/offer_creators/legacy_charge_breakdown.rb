# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class LegacyChargeBreakdown < OfferCalculator::Service::OfferCreators::Base
        def self.charge_breakdown(offer:, shipment:, tender:)
          new(offer: offer, shipment: shipment, tender: tender).perform
        end

        def initialize(offer:, shipment:, tender:)
          @offer = offer
          @tender = tender
          super(shipment: shipment)
        end

        def perform
          offer.sections.each do |section_charges|
            if section_charges.first.section.include?("trucking")
              build_trucking_section(section_charges: section_charges)
            else
              build_section(section_charges: section_charges)
            end
          end
          charge_breakdown
        end

        private

        attr_reader :shipment, :tender, :currency, :offer

        def charge_breakdown
          @charge_breakdown ||= Legacy::ChargeBreakdown.create(
            shipment: shipment,
            trip_id: offer.schedules.first.trip_id,
            freight_tenant_vehicle: offer.tenant_vehicle(section_key: "cargo"),
            pickup_tenant_vehicle: offer.tenant_vehicle(section_key: "trucking_pre"),
            delivery_tenant_vehicle: offer.tenant_vehicle(section_key: "trucking_on"),
            valid_until: offer.valid_until,
            tender_id: tender.id
          )
        end

        def grand_total_charge
          @grand_total_charge ||= Legacy::Charge.create(
            children_charge_category: Legacy::ChargeCategory.from_code(
              code: "grand_total", name: "Grand Total", organization_id: shipment.organization_id
            ),
            charge_category: Legacy::ChargeCategory.from_code(
              code: "base_node", name: "Base Node", organization_id: shipment.organization_id
            ),
            charge_breakdown: charge_breakdown,
            price: Legacy::Price.create(
              currency: currency,
              value: offer.total.exchange_to(currency).cents / 100.0
            )
          )
        end

        def build_section(section_charges:)
          section_charge = build_section_charge(charges: section_charges)
          section_charges.group_by(&:cargo).each do |target, charges|
            cargo_charge = build_cargo_charge(fees: charges, section_charge: section_charge, target: target)
            build_child_charges(fees: charges, cargo_charge: cargo_charge)
          end
        end

        def build_trucking_section(section_charges:)
          section_charge = build_section_charge(charges: section_charges)
          section_charges.group_by(&:cargo).values.each do |charges|
            cargo_charge = build_trucking_cargo_charge(fees: charges, section_charge: section_charge)
            build_child_charges(fees: charges, cargo_charge: cargo_charge)
          end
        end

        def build_cargo_charge(fees:, section_charge:, target:)
          Legacy::Charge.create(
            charge_category: section_charge.children_charge_category,
            children_charge_category: cargo_charge_category(target: target),
            charge_breakdown: charge_breakdown,
            parent: section_charge,
            price: price_from_fees_in_user_currency(fees: fees)
          )
        end

        def build_trucking_cargo_charge(fees:, section_charge:)
          Legacy::Charge.create(
            charge_category: section_charge.children_charge_category,
            children_charge_category: trucking_cargo_charge_category(fee: fees.first),
            charge_breakdown: charge_breakdown,
            parent: section_charge,
            price: price_from_fees_in_user_currency(fees: fees)
          )
        end

        def build_section_charge(charges:)
          Legacy::Charge.create(
            charge_category: grand_total_charge.children_charge_category,
            children_charge_category: build_section_charge_category(charges: charges),
            charge_breakdown: charge_breakdown,
            parent: grand_total_charge,
            price: price_from_fees_in_user_currency(fees: charges)
          )
        end

        def price_from_fees_in_user_currency(fees:)
          money = fees.sum(&:value).exchange_to(currency)
          price_from_money(money: money)
        end

        def price_from_money(money:)
          Legacy::Price.create(value: money.cents / 100.0, currency: money.currency.iso_code)
        end

        def build_child_charges(fees:, cargo_charge:)
          fees.each do |fee|
            Legacy::Charge.create(
              charge_category: cargo_charge.children_charge_category,
              children_charge_category: fee.charge_category,
              charge_breakdown: charge_breakdown,
              parent: cargo_charge,
              line_item_id: fee.line_item.id,
              price: price_from_money(money: fee.value)
            )
          end
        end

        def build_section_charge_category(charges:)
          Legacy::ChargeCategory.from_code(code: charges.first.section, organization_id: shipment.organization_id)
        end

        def cargo_charge_category(target:)
          legacy_cargo_code, legacy_cargo_id = legacy_cargo_code_and_id(target: target)
          Legacy::ChargeCategory.from_code(
            code: legacy_cargo_code,
            organization_id: shipment.organization_id,
            cargo_unit_id: legacy_cargo_id
          )
        end

        def trucking_cargo_charge_category(fee:)
          Legacy::ChargeCategory.from_code(
            code: fee.cargo ? "trucking_#{fee.cargo_class}" : "shipment",
            organization_id: shipment.organization_id
          )
        end

        def legacy_cargo_code_and_id(target:)
          if target.nil?
            ["shipment", nil]
          else
            legacy_cargo = legacy_cargo_from_target(target: target)
            [
              legacy_cargo.is_a?(Legacy::Container) ? "container" : "cargo_item",
              legacy_cargo&.id
            ]
          end
        end
      end
    end
  end
end
