# frozen_string_literal: true

module ChargeCalculator
  module Models
    class CargoUnit < Base
      #   Attribute   |   Unit
      #
      #   dimensions  |   --
      #     x         |   cm
      #     y         |   cm
      #     z         |   cm
      #   volume      |   m3
      #   payload     |   kg

      def volume
        @volume ||= data.fetch(:volume) { volume_from_dimensions }
      end

      def price(pricing:)
        Models::Price.new(
          children: prices(pricing: pricing),
          category: :cargo_unit,
          description: "cargo_unit_#{id}".to_sym
        )
      end

      def prices(pricing:)
        pricing.cargo_unit_rates.map do |rate|
          rate.price(context: context(pricing))
        end
      end

      def goods_value
        BigDecimal(data.fetch(:goods_value))
      end

      private

      def context(pricing)
        Contexts::CargoUnit.new(pricing: pricing, cargo_unit: self)
      end

      def volume_from_dimensions
        return nil if self[:dimensions].nil?

        self[:dimensions].values.reduce(1) { |acc, v| acc * BigDecimal(v) } / 1_000_000
      end
    end
  end
end
