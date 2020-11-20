# frozen_string_literal: true

module RateExtractor
  module Decorators
    class CargoRate < Draper::Decorator
      delegate_all
      attr_writer :targets

      def rate_charged_cargos(cargo:, consolidation:)
        if consolidation
          [RateExtractor::Decorators::RateChargedCargo.new(cargo, context: {rate: self})]
        else
          cargo.units.map do |unit|
            RateExtractor::Decorators::RateChargedCargo.new(unit, context: {rate: self})
          end
        end
      end

      def targets
        @targets ||= []
      end
    end
  end
end
