# frozen_string_literal: true

module ChargeCalculator
  class HashDataDump
    def initialize(data: {})
      @data = data
    end

    def [](key)
      data[key]
    end

    def method_missing(method_name, *args, &block)
      data[method_name.to_sym] || super
    end

    def respond_to_missing?(method_name, *args, &block)
      data[method_name.to_sym] || super
    end

    private

    attr_reader :data
  end
end
