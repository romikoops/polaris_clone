# frozen_string_literal: true

module ChargeCalculator
  module Contexts
    class Shipment < Base
      def initialize(data: {})
        @data = data
      end

      private

      attr_reader :data

      alias hash data
    end
  end
end
