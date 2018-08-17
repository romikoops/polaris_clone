# frozen_string_literal: true

module ChargeCalculator
  module Contexts
    class Shipment < Base
      def hash
        { flat: 1 }
      end
    end
  end
end
