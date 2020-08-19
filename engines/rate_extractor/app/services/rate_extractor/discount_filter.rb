# frozen_string_literal: true

module RateExtractor
  class DiscountFilter
    def initialize(organization:, tender:, user:, cargo:, desired_date:)
      @organization = organization
      @tender = tender
      @user = user
      @cargo = RateExtractor::Decorators::Cargo.new(cargo)
      @desired_date = desired_date
    end

    def discounts
      @discounts = Rates::Discount.where(organization: organization)
      @discounts = validity_filtered
      @discounts = applicable_filtered
      @discounts = target_filtered
      @discounts = range_filtered
    end

    def validity_filtered
      @discounts.where("validity @> ?::date", desired_date)
    end

    def applicable_filtered
      @discounts.where(applicable_to: hierarchy)
    end

    def target_filtered
      @discounts.where(target: [*section_rates, *cargo_rates]).or(@discounts.where(target: nil))
    end

    def range_filtered
      @discounts.where("kg_range @> ?::numeric", cargo.weight.value)
        .where("cbm_range @> ?::numeric", cargo.volume.value)
        .where("unit_range @> ?::numeric", cargo.quantity)
    end

    private

    attr_reader :organization, :cargo, :user, :desired_date, :tender

    def hierarchy
      OrganizationManager::HierarchyService.new(target: user, organization: organization).fetch
    end

    def section_rates
      Section.new(organization: organization, user: user, path: tender.path).rates
    end

    def cargo_rates
      CargoRates.new(section_rates: section_rates, cargo: cargo).rates
    end
  end
end
