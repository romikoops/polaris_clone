# frozen_string_literal: true

module ChargeCalculator
  module Models
    class Pricing < Base
      def cargo_unit_rates
        @cargo_unit_rates ||= rates_for("cargo_unit")
      end

      def shipment_rates
        @shipment_rates ||= rates_for("shipment")
      end

      def weight_measure
        BigDecimal(data.dig(:conversion_ratios, :weight_measure))
      end

      private

      def rates_for(kind)
        rates.select { |rate| rate[:kind] == kind }
      end
    end
  end
end
