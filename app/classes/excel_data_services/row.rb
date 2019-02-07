# frozen_string_literal: true

module ExcelDataServices
  class Row
    def initialize(row_data:, tenant:)
      @data = row_data
      @tenant = tenant
    end

    def itinerary
      @itinerary ||= Itinerary.find_by(name: itinerary_name, tenant: tenant)
    end

    def itinerary_name
      @itinerary_name ||= [data[:origin], data[:destination]].join(' - ')
    end

    def cargo_classes
      @cargo_classes ||= if data[:load_type].casecmp('fcl').zero?
                           %w(fcl_20 fcl_40 fcl_40_hq)
                         else
                           [data[:load_type].downcase]
                         end
    end

    def tenant_vehicle
      @tenant_vehicle ||= TenantVehicle.find_by(
        tenant: tenant,
        name: data[:service_level],
        carrier: carrier,
        mode_of_transport: data[:mot]
      )
    end

    def carrier
      @carrier ||= Carrier.find_by_name(data[:carrier]) unless data[:carrier].blank?
    end

    def user
      @user ||= User.find_by(tenant: tenant, email: data[:customer_email]) if data[:customer_email].present?
    end

    def uuid
      @uuid ||= data[:uuid]
    end

    def effective_date
      @effective_date ||= data[:effective_date]
    end

    def expiration_date
      @expiration_date ||= data[:expiration_date]
    end

    private

    attr_reader :data, :tenant
  end
end
