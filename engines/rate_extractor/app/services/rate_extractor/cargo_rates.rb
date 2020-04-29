# frozen_string_literal: true

module RateExtractor
  class CargoRates
    def initialize(section_rates:, cargo:, sandbox: nil)
      @section_rates = section_rates
      @cargo = cargo
      @sandbox = sandbox
    end

    def rates
      RateExtractor::Decorators::CargoRate.new(
        Rates::Cargo.where(section: section_rates)
                    .where(cargo_class: cargo_classes)
                    .where(cargo_type: cargo_types)
      )
    end

    private

    attr_reader :section_rates, :tenant, :cargo

    def cargo_classes
      cargo.units.object.select(:cargo_class).distinct
    end

    def cargo_types
      cargo.units.object.select(:cargo_type).distinct
    end
  end
end
