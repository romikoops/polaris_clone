# frozen_string_literal: true

module ChargeCalculator
  module Contexts
    class Shipment < Base
      def initialize(data: {})
        @data = data
      end

      def hash
        @hash ||= {
          bills_of_lading: data[:bills_of_lading]
        }
      end

      private

      attr_reader :data
    end
  end
end
