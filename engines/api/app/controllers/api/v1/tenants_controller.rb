# frozen_string_literal: true

module Api
  module V1
    class TenantsController < ApiController
      def index
        tenants = TenantDecorator.decorate_collection([current_tenant])
        render json: TenantSerializer.new(tenants)
      end

      def scope
        scope = Tenants::ScopeService.new(tenant: current_tenant, target: current_user).fetch

        render json: scope
      end

      def countries
        countries = Legacy::Hub.where(tenant: current_tenant.legacy).collect(&:country).uniq
        render json: CountrySerializer.new(countries)
      end
    end
  end
end
