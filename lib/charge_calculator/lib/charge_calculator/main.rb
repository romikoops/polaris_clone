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
            context: context(pricing, cargo_unit)
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

    def context(pricing, cargo_unit)
      {
        quantity:           cargo_unit[:quantity],
        payload:            BigDecimal(cargo_unit[:payload]),
        chargeable_payload: chargeable_payload(pricing, cargo_unit),
        dimensions:         cargo_unit[:dimensions],
        volume:             cargo_unit.volume
      }
    end

    def chargeable_payload(pricing, cargo_unit)
      [
        cargo_unit.volume * BigDecimal(pricing.dig(:conversion_ratios, :weight_measure)),
        BigDecimal(cargo_unit[:payload])
      ].max
    end
  end
end
