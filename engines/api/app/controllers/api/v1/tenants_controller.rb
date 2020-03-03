# frozen_string_literal: true

module Api
  module V1
    class TenantsController < ApiController
      def index
        tenants = TenantDecorator.decorate_collection([current_tenant])
        render json: tenants, each_serializer: TenantSerializer
      end
    end
  end
end
