module Api
  module V1
    class ClientsController < ApiController
      def index
        blocked_roles = Legacy::Role.where(name: %w(admin super_admin))
        client_ids = Legacy::User
                     .where(tenant_id: current_tenant.legacy_id)
                     .where(guest: false)
                     .where.not(role: blocked_roles)
                     .ids

        render json: Tenants::User.where(legacy_id: client_ids), each_serializer: UserSerializer
      end

      def show
        client = Tenants::User.find_by(legacy_id: params[:id])
        render json: client, serializer: UserSerializer
      end
    end
  end
end
