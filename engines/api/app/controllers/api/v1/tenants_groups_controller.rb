# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class TenantsGroupsController < ApiController
      def index
        tenants_groups = Tenants::Group.where(tenant_id: current_tenant.id)
        render json: TenantsGroupSerializer.new(tenants_groups)
      end
    end
  end
end
