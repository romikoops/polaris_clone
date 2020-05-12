# frozen_string_literal: true

module RateExtractor
  module Decorators
    class SectionRate < Draper::Decorator
      delegate_all

      decorates_association :cargos, with: RateExtractor::Decorators::CargoRate

      def carriage_distance; end
    end
  end
end
