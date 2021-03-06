# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Calculator
      class Shipment < Base
        delegate :amount, to: :fee
      end
    end
  end
end
