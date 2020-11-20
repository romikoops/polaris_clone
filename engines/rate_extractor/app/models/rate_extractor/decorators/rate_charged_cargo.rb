# frozen_string_literal: true

module RateExtractor
  module Decorators
    class RateChargedCargo < Draper::Decorator
      delegate_all

      decorates_association :units, with: RateChargedCargo,
                                    context: ->(parent_context) { parent_context }

      def weight_measure
        [total_weight, volumetric_weight].max
      end

      def volumetric_weight
        Measured::Weight.new(total_volume.value * rate.cbm_ratio, :kg)
      end

      def chargeable_weight
        RateExtractor::ChargeableWeight::Calculator.weight(
          rate: rate,
          cargo: self
        )
      end

      def route_distance
      end

      private

      def rate
        context[:rate]
      end
    end
  end
end
