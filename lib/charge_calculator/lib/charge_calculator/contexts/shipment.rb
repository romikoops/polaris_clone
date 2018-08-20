# frozen_string_literal: true

module ChargeCalculator
  module Contexts
    class Shipment < Base
      def initialize(data: {})
        @data = data
      end

      def hash
        data
      end

      private

      attr_reader :data
    end
  end
end
