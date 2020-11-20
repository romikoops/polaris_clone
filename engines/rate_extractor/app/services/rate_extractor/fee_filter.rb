# frozen_string_literal: true

module RateExtractor
  class FeeFilter
    attr_accessor :chargeable_cargos

    def initialize(consolidation:, desired_date:, cargo_rate:, section_rate:, cargo:)
      @desired_date = desired_date
      @cargo_rate = RateExtractor::Decorators::CargoRate.new(cargo_rate)
      @section_rate = RateExtractor::Decorators::SectionRate.new(section_rate)
      @chargeable_cargos = @cargo_rate.rate_charged_cargos(cargo: cargo, consolidation: consolidation)
    end

    def fees
      @fees = Rates::Fee.where(cargo_id: cargo_rate.id)
      @fees = validity_filtered
      @fees = range_filtered
    end

    private

    attr_reader :cargo_rate, :section_rate, :desired_date, :cargo

    def validity_filtered
      @fees.where("validity @> ?::date", desired_date)
    end

    def range_filtered
      range_filtered_fees = Rates::Fee.none
      chargeable_cargos.each do |chargeable_cargo|
        range_filtered_fees = range_filtered_fees.or(
          @fees.where("kg_range @> ?::numeric", chargeable_cargo.chargeable_weight.value)
              .where("km_range @> ?::numeric", section_rate.carriage_distance)
              .where("cbm_range @> ?::numeric", chargeable_cargo.volume.value)
              .where("wm_range @> ?::numeric", chargeable_cargo.weight_measure.value)
              .where("stowage_range @> ?::numeric", chargeable_cargo.stowage_factor.value)
              .where("unit_range @> ?::numeric", chargeable_cargo.quantity)
        )
        # to add cargo as target on the cargo rate
        @cargo_rate.targets << chargeable_cargo if range_filtered_fees.any?
      end
      range_filtered_fees
    end
  end
end
