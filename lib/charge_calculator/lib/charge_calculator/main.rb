# frozen_string_literal: true

module ChargeCalculator
  class Main
    def initialize(shipment_params:, pricings:)
      @shipment_params = shipment_params
      @pricings        = pricings

      @cargo_units = shipment_params[:cargo_units].map do |cargo_unit_hash|
        CargoUnit.new(cargo_unit_hash)
      end
    end

    def price
      @price ||= perform
    end

    private

    attr_reader :pricings, :shipment_params, :cargo_units

    def perform
      prices = pricings.map do |pricing|
        pricing_prices = cargo_units.map do |cargo_unit|
          calculation = Calculation.new(
            rates:   pricing[:rates],
            context: Context.new(pricing: pricing, cargo_unit: cargo_unit)
          )

          cargo_unit_prices = calculation.result.map do |price_attributes|
            Price.new(price_attributes)
          end

          Price.new(
            children:    cargo_unit_prices,
            category:    "cargo_unit",
            description: "cargo_unit_#{cargo_unit[:id]}"
          )
        end

        Price.new(
          children:    pricing_prices,
          category:    "route",
          description: pricing[:route]
        )
      end

      Price.new(children: prices, category: "base", description: "Base")
    end
  end
end
