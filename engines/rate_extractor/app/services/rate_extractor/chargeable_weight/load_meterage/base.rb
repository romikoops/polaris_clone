# frozen_string_literal: true

module RateExtractor
  module ChargeableWeight
    module LoadMeterage
      class Base
        attr_reader :ldm_threshold, :ldm_ratio, :ldm_area_divisor, :truck_height, :rate, :cargo
        delegate :ldm_threshold, :ldm_ratio, :ldm_area_divisor, :truck_height, to: :rate

        def initialize(rate:, cargo:)
          @rate = rate
          @cargo = cargo
        end

        def cargo_ldm_weight(measurement:)
          return cargo.total_weight unless ldm_threshold_exceeded?(measurement: measurement)

          Measured::Weight.new(cargo.total_area.value / ldm_area_divisor * ldm_ratio, :kg)
        end

        def ldm_threshold_exceeded?(measurement:)
          measurement >= ldm_threshold
        end
      end
    end
  end
end
