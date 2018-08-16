# frozen_string_literal: true

module ChargeCalculator
  class Main
    def initialize(shipment_params:, pricings:)
      @shipment_params = shipment_params
      @pricings        = pricings
    end

    def price
      @price ||= perform
    end

    private

    attr_reader :pricings, :shipment_params

    def perform
      prices = pricings.map do |pricing|
        pricing_prices = shipment_params[:cargo_units].map do |cargo_unit|
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
      volume = volume(cargo_unit)

      {
        quantity:           cargo_unit[:quantity],
        payload:            BigDecimal(cargo_unit[:payload]),
        chargeable_payload: chargeable_payload(pricing, cargo_unit, volume),
        dimensions:         cargo_unit[:dimensions],
        volume:             volume
      }
    end

    def chargeable_payload(pricing, cargo_unit, volume)
      [
        volume * BigDecimal(pricing.dig(:conversion_ratios, :weight_measure)),
        BigDecimal(cargo_unit[:payload])
      ].max
    end

    def volume(cargo_unit)
      BigDecimal(cargo_unit[:volume] || volume_from_dimensions(cargo_unit[:dimensions]))
    end

    def volume_from_dimensions(dimensions)
      dimensions.values.reduce(1) { |acc, v| acc * BigDecimal(v) } / 1_000_000
    end
  end
end
