# frozen_string_literal: true

module Api
  module V1
    class TenantsController < ApiController
      def index
        tenants = TenantDecorator.decorate_collection([current_tenant])
        render json: tenants, each_serializer: TenantSerializer
      end

      def scope
        scope = Tenants::ScopeService.new(tenant: current_tenant, target: current_user).fetch

        render json: scope
      end
    end
  end
end
