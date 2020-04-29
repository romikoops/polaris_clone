# frozen_string_literal: true

module RateExtractor
  module Decorators
    class CargoRate < SimpleDelegator
      def rate_charged_cargos(cargo:, consolidation:)
        if consolidation
          [RateExtractor::Decorators::RateChargedCargo.new(cargo, context: { rate: self })]
        else
          cargo.units.map do |unit|
            RateExtractor::Decorators::RateChargedCargo.new(unit, context: { rate: self })
          end
        end
      end
    end
  end
end
