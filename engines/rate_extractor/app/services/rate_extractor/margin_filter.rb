# frozen_string_literal: true

module RateExtractor
  class MarginFilter
    def initialize(organization:, tender:, user:, cargo:, desired_date:)
      @organization = organization
      @tender = tender
      @user = user
      @cargo = RateExtractor::Decorators::Cargo.new(cargo)
      @desired_date = desired_date
    end

    def margins
      @margins = Rates::Margin.where(organization: organization)
      @margins = validity_filtered
      @margins = applicable_filtered
      @margins = target_filtered
    end

    def validity_filtered
      @margins.where("validity @> ?::date", desired_date)
    end

    def applicable_filtered
      @margins.where(applicable_to: hierarchy)
    end

    def target_filtered
      @margins.where(target: [*section_rates, *cargo_rates]).or(@margins.where(target: nil))
    end

    private

    attr_reader :organization, :cargo, :desired_date, :user, :tender

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
