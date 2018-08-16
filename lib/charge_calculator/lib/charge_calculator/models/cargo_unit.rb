# frozen_string_literal: true

module ChargeCalculator
  class CargoUnit
    def initialize(args={})
      args.each do |name, v|
        instance_variable_set("@#{name}", v)
      end
    end

    def volume
      @volume ||= volume_from_dimensions
    end

    def [](key)
      instance_variable_get("@#{key}")
    end

    private

    def volume_from_dimensions
      return nil if self[:dimensions].nil?

      self[:dimensions].values.reduce(1) { |acc, v| acc * BigDecimal(v) } / 1_000_000
    end

    attr_reader :data
  end
end
