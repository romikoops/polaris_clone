# frozen_string_literal: true

module ChargeCalculator
  class CargoUnit
    def initialize(data: {})
      @data = data
    end

    def volume
      @volume ||= data.fetch(:volume) { volume_from_dimensions }
    end

    def [](key)
      data[key]
    end

    def method_missing(method_name, *args, &block)
      data[method_name.to_sym] || super
    end

    private

    attr_reader :data

    def volume_from_dimensions
      return nil if self[:dimensions].nil?

      self[:dimensions].values.reduce(1) { |acc, v| acc * BigDecimal(v) } / 1_000_000
    end
  end
end
