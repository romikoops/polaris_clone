module Api
  module V1
    class ClientsController < ApiController
      def index
        blocked_roles = Legacy::Role.where(name: %w(admin super_admin))
        clients = Legacy::User.where(tenant_id: current_tenant.legacy_id)
                              .where(guest: false)
                              .where.not(role: blocked_roles)
                              .order(first_name: :asc)

        render json: clients, each_serializer: Legacy::UserSerializer
      end

      def show
        client = Legacy::User.find(params[:id])
        render json: client, serializer: Legacy::UserSerializer
      end
    end
  end
end
