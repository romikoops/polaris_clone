# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      class FeeBuilder < OfferCalculator::Service::RateBuilders::Base
        delegate :object, to: :measures
        MAX_KEYS = %w[max max_value maximum].freeze
        MIN_KEYS = %w[min min_value minimum].freeze

        def self.fee(request:, fee:, code:, measures:)
          new(request: request, fee: fee, code: code, measures: measures).perform
        end

        def initialize(request:, fee:, code:, measures:)
          @fee = fee
          @code = code.downcase
          super(request: request, measures: measures)
        end

        def perform
          fee_inputs = FeeInputs.new(
            charge_category: find_charge_category_from_breakdowns,
            rate_basis: fee.fetch("rate_basis"),
            min_value: min_value,
            max_value: max_value,
            measures: measures,
            targets: determine_targets(rate_basis: fee.fetch("rate_basis"))
          )

          OfferCalculator::Service::RateBuilders::Fee.new(inputs: fee_inputs)
        end

        private

        attr_reader :request, :measures, :code, :fee

        def find_charge_category_from_breakdowns
          object.breakdowns.find { |breakdown| breakdown.code == code }&.charge_category
        end

        def min_value
          value_in_cents = (fee.values_at(*MIN_KEYS).find(&:present?) || 0).to_d * 100.0
          Money.new(value_in_cents, fee["currency"])
        end

        def max_value
          value_in_cents = (fee.values_at(*MAX_KEYS).find(&:present?) || DEFAULT_MAX).to_d * 100.0
          Money.new(value_in_cents, fee["currency"])
        end
      end
    end
  end
end
