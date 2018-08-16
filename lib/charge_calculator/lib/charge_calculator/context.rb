# frozen_string_literal: true

module ChargeCalculator
  class Context
    def initialize(pricing:, cargo_unit:)
      @pricing    = pricing
      @cargo_unit = cargo_unit
    end

    def to_h
      hash
    end

    def hash
      @hash ||= {
        payload:            BigDecimal(cargo_unit[:payload]),
        volume:             cargo_unit.volume,
        dimensions:         cargo_unit[:dimensions],
        quantity:           cargo_unit[:quantity],
        chargeable_payload: chargeable_payload
      }
    end

    def fetch(key, default=nil, &block)
      hash.fetch(key, default, &block)
    end

    def [](key)
      hash[key].is_a?(Proc) ? hash[key].call(self) : hash[key]
    end

    private

    def chargeable_payload
      lambda do |context|
        [
          context[:payload],
          context[:volume] * BigDecimal(pricing.dig(:conversion_ratios, :weight_measure))
        ].max
      end
    end

    attr_reader :pricing, :cargo_unit
  end
end
