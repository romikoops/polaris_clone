# frozen_string_literal: true

module ChargeCalculator
  class Context
    extend Forwardable
    def_delegator :hash, :fetch

    def initialize(pricing:, cargo_unit:)
      @pricing    = pricing
      @cargo_unit = cargo_unit
    end

    def to_h
      hash
    end

    def hash
      @hash ||= {
        payload:            BigDecimal(cargo_unit.payload),
        volume:             BigDecimal(cargo_unit.volume),
        dimensions:         dimensions,
        quantity:           cargo_unit.quantity.to_i,
        chargeable_payload: chargeable_payload
      }
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

    def dimensions
      lambda do |_context|
        cargo_unit.dimensions.each_with_object({}) do |(name, value), obj|
          obj[name] = BigDecimal(value)
        end
      end
    end

    attr_reader :pricing, :cargo_unit
  end
end
