# frozen_string_literal: true

module Legacy
  module ExchangeHelper
    def self.sum_and_convert(hash_obj, base)
      hash_obj.inject(Money.new(0, base)) do |sum, (key, value)|
        sum + Money.new(value * 100.0, key)
      end
    end

    def self.convert(value, from, to)
      Money.new(value * 100.0, from).exchange_to(to)
    end

    def self.sum_and_convert_cargo(hash_obj, base)
      hash_obj.values
        .reject(&:empty?)
        .inject(Money.new(0, base)) do |sum, charge|
        sum + Money.new(charge["value"] * 100.0, charge["currency"])
      end
    end
  end
end
