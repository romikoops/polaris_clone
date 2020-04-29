# frozen_string_literal: true

module RateExtractor
  module Decorators
    class Cargo < Draper::Decorator
      delegate_all

      def quantity
        object.units.sum(&:quantity)
      end

      def units
        UnitDecorator.decorate_collection(object.units)
      end
    end
  end
end
