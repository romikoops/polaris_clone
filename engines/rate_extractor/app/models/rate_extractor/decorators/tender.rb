# frozen_string_literal: true

module RateExtractor
  module Decorators
    class Tender < SimpleDelegator
      attr_accessor :path
      attr_writer :fees

      def fees
        @fees ||= []
      end
    end
  end
end
