# frozen_string_literal: true

module RateExtractor
  module ChargeableWeight
    module Applicable
      class Base
        attr_reader :ldm_threshold, :ldm_ratio, :ldm_measurement, :cargo,
          :section_rate, :cargo_rate, :cbm_ratio

        delegate :ldm_threshold, :ldm_ratio, :ldm_measurement, to: :section_rate
        delegate :cbm_ratio, to: :cargo_rate

        def initialize(cargo_rate:, cargo:)
          @cargo_rate = cargo_rate
          @section_rate = cargo_rate.section
          @cargo = cargo
        end
      end
    end
  end
end
