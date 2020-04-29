# frozen_string_literal: true

module RateExtractor
  module Decorators
    class UnitDecorator < Draper::Decorator
      delegate_all
    end
  end
end
