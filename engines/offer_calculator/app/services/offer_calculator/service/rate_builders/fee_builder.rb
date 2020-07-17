# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      class FeeBuilder < Base
        delegate :object, to: :measures

        def self.fee(quotation:, fee:, code:, measures:)
          new(quotation: quotation, fee: fee, code: code, measures: measures).perform
        end

        def initialize(quotation:, fee:, code:, measures:)
          @quotation = quotation
          @measures = measures
          @fee = fee
          @code = code.downcase
        end

        def perform
          fee_inputs = Struct::FeeInputs.new(
            find_charge_category_from_breakdowns,
            fee.fetch("rate_basis"),
            min_value,
            max_value,
            measures,
            determine_target(rate_basis: fee.fetch("rate_basis"))
          )
          OfferCalculator::Service::RateBuilders::Fee.new(inputs: fee_inputs)
        end

        private

        attr_reader :quotation, :measures, :code, :fee

        def find_charge_category_from_breakdowns
          object.breakdowns.find { |breakdown| breakdown.code == code }&.charge_category
        end

        def min_value
          value_in_cents = (fee.dig("min") || fee.dig("min_value") || 0) * 100.0
          Money.new(value_in_cents, fee.dig("currency"))
        end

        def max_value
          value_in_cents = (fee.dig("max") || fee.dig("max_value") || DEFAULT_MAX) * 100.0
          Money.new(value_in_cents, fee.dig("currency"))
        end
      end
    end
  end
end
