# frozen_string_literal: true

require "active_support/time"

module MoneyCache
  class Conversion
    def self.rate(from:, to:, store:, base:)
      new(from: from, to: to, store: store, base: base).perform
    end

    def initialize(from:, to:, store:, base:)
      @from = from
      @to = to
      @base = base
      @store = store
    end

    def perform
      (get_stored_rate || get_inverse_rate || get_calculated_rate).round(6)
    end

    private

    attr_reader :store, :from, :to, :base

    def get_stored_rate
      store.get_rate(from, to)
    end

    def get_inverse_rate(from_currency: from, to_currency: to)
      inverse_rate = store.get_rate(to_currency, from_currency)
      return unless inverse_rate

      rate = 1.0 / inverse_rate
      store.add_rate(from_currency, to_currency, rate)
    end

    def get_calculated_rate
      return unless to_base_rate && from_base_rate

      rate = to_base_rate.to_d / from_base_rate
      store.add_rate(from, to, rate)
      rate
    end

    def from_base_rate
      @from_base_rate ||= store.get_rate(from, base) || get_inverse_rate(from_currency: base, to_currency: from)
    end

    def to_base_rate
      @to_base_rate ||= store.get_rate(base, to) || get_inverse_rate(from_currency: to, to_currency: base)
    end
  end
end
