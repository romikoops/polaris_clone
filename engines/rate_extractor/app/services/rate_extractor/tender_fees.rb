# frozen_string_literal: true

module RateExtractor
  class TenderFees
    attr_reader :cargo, :tenant, :desired_date
    attr_accessor :tender

    def initialize(tenant:, tender:, cargo:, desired_date:, sandbox: nil)
      @tenant = tenant
      @tender = tender
      @cargo = RateExtractor::Decorators::Cargo.new(cargo)
      @desired_date = desired_date
    end

    def fees
      section_rates.each do |section_rate|
        section_cargo_rates = cargo_rates.where(section: section_rate)
        section_cargo_rates.each do |cargo_rate|
          tender.fees << fee_filter(cargo_rate: cargo_rate, section_rate: section_rate).fees
        end
      end
      tender.fees
    end

    def section_rates
      Section.new(tenant: tenant, path: tender.path).rates
    end

    def cargo_rates
      CargoRates.new(section_rates: section_rates, cargo: cargo).rates
    end

    private

    def fee_filter(cargo_rate:, section_rate:)
      FeeFilter.new(consolidation: consolidation,
                    desired_date: desired_date,
                    section_rate: section_rate,
                    cargo_rate: cargo_rate,
                    cargo: cargo)
    end

    def consolidation
      consolidation = Tenants::ScopeService.new(target: nil, tenant: tenant).fetch(:consolidation)
      consolidation['trucking']['calculation']
    end
  end
end
