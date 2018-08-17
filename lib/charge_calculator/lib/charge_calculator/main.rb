# frozen_string_literal: true

module ChargeCalculator
  class Main
    def initialize(shipment_params:, pricings:)
      @pricings = pricings.map do |pricing_hash|
        Pricing.new(data: pricing_hash)
      end

      @cargo_units = shipment_params[:cargo_units].map do |cargo_unit_hash|
        CargoUnit.new(data: cargo_unit_hash)
      end
    end

    def price
      @price ||= perform
    end

    private

    attr_reader :pricings, :cargo_units

    def perform
      prices = pricings.map do |pricing|
        shipment_calculation = Calculation.new(
          rates:   pricing.shipment_rates,
          context: Contexts::Shipment.new
        )

        pricing_cargo_unit_prices = cargo_units.map do |cargo_unit|
          cargo_unit_calculation = Calculation.new(
            rates:   pricing.cargo_unit_rates,
            context: Contexts::CargoUnit.new(pricing: pricing, cargo_unit: cargo_unit)
          )

          Price.new(
            children:    cargo_unit_calculation.prices,
            category:    "cargo_unit",
            description: "cargo_unit_#{cargo_unit[:id]}"
          )
        end

        Price.new(
          children:    [*shipment_calculation.prices, *pricing_cargo_unit_prices],
          category:    "route",
          description: pricing.route
        )
      end

      Price.new(children: prices, category: "base", description: "Base")
    end

    def cargo_unit_rates
    end
  end
end
