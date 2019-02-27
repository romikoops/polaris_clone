# frozen_string_literal: true

module ChargeCalculator
  class Main
    def initialize(shipment_params:, pricings:)
      @pricings = pricings.map do |pricing_hash|
        Models::Pricing.new(pricing_hash)
      end

      @cargo_units = shipment_params.fetch(:cargo_units) { [] }.map do |cargo_unit_hash|
        Models::CargoUnit.new(data: cargo_unit_hash)
      end
    end

    def price
      @price ||= perform
    end

    private

    attr_reader :pricings, :cargo_units

    def perform
      prices = pricings.map do |pricing|
        pricing_shipment_prices = pricing.shipment_rates.map do |rate|
          rate.price(context: Contexts::Shipment.new)
        end

        pricing_cargo_unit_prices = cargo_units.map do |cargo_unit|
          cargo_unit.price(pricing: pricing)
        end

        Models::Price.new(
          children: [*pricing_shipment_prices, *pricing_cargo_unit_prices],
          category: :route,
          description: pricing.route
        )
      end

      Models::Price.new(children: prices, category: :base, description: :Base)
    end
  end
end
