# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    NoSuchCalculatorError = Class.new(StandardError)

    CALCULATORS = {
      bill_of_lading: BillOfLading,
      volume: Volume,
      payload: Payload,
      payload_unit_100_kg: PayloadUnit100Kg,
      payload_unit_ton: PayloadUnitTon,
      chargeable_payload: ChargeablePayload,
      weight_measure: WeightMeasure,
      flat: Flat
    }.freeze

    def self.get(key)
      raise NoSuchCalculatorError, "The Calculator '#{key}' doesn't exist" unless CALCULATORS.has_key? key

      CALCULATORS[key].new
    end
  end
end
