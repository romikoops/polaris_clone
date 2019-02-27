# frozen_string_literal: true

module ChargeCalculator
  module Models
    class Pricing
      attr_reader :conversion_ratios, :route

      def initialize(conversion_ratios:, route:, rates:, direction: nil)
        @conversion_ratios = conversion_ratios
        @route = route
        @rates = rates.map { |rate_hash| Models::Rate.new(rate_hash) }
        @direction = direction
      end

      def cargo_unit_rates
        @cargo_unit_rates ||= rates_for('cargo_unit')
      end

      def shipment_rates
        @shipment_rates ||= rates_for('shipment')
      end

      def weight_measure
        BigDecimal(conversion_ratios[:weight_measure])
      end

      private

      attr_reader :rates

      def rates_for(kind)
        rates.select { |rate| rate.kind?(kind) }
      end
    end
  end
end
