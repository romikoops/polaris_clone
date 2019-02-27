# frozen_string_literal: true

module ChargeCalculator
  module Contexts
    class CargoUnit < Base
      def initialize(pricing:, cargo_unit:)
        @pricing    = pricing
        @cargo_unit = cargo_unit
      end

      private

      attr_reader :pricing, :cargo_unit

      def hash
        @hash ||= {
          payload: BigDecimal(cargo_unit.payload),
          volume: BigDecimal(cargo_unit.volume),
          dimensions: dimensions,
          quantity: cargo_unit.quantity.to_i,
          chargeable_payload: chargeable_payload,
          weight_measure: weight_measure,
          goods_value: cargo_unit.goods_value
        }
      end

      def chargeable_payload
        lambda do |context|
          [
            context[:payload],
            context[:volume] * pricing.weight_measure
          ].max
        end
      end

      def weight_measure
        lambda do |context|
          [
            context[:payload] / pricing.weight_measure,
            context[:volume]
          ].max
        end
      end

      def dimensions
        lambda do |_context|
          cargo_unit.dimensions.each_with_object({}) do |(name, value), obj|
            obj[name] = BigDecimal(value)
          end
        end
      end
    end
  end
end
