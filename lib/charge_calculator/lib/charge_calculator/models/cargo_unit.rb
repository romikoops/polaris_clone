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

    private

    attr_reader :data

    def volume_from_dimensions
      return nil if self[:dimensions].nil?

      self[:dimensions].values.reduce(1) { |acc, v| acc * BigDecimal(v) } / 1_000_000
    end
  end
end
