# frozen_string_literal: true

module RateExtractor
  module ChargeableWeight
    class Calculator
      def self.weight(rate:, cargo:)
        section_rate = rate.section
        applicable = section_rate.ldm_threshold_applicable || "default"
        "RateExtractor::ChargeableWeight::Applicable::#{applicable.camelize}"
          .constantize
          .new(cargo_rate: rate, cargo: cargo)
          .chargeable_weight
      end
    end
  end
end
