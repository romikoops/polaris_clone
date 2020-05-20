# frozen_string_literal: true

module Api
  module V1
    class ClientsController < ApiController
      def index
        render json: UserSerializer.new(decorated_clients)
      end

      def show
        render json: UserSerializer.new(UserDecorator.decorate(client))
      end

      def create
        ActiveRecord::Base.transaction do
          client = Legacy::User.create!(email: client_params[:email],
                                        tenant_id: current_tenant.legacy_id,
                                        addresses_attributes: [address_from_params],
                                        role: Legacy::Role.find_by(name: client_params.fetch(:role, 'shipper')))
          tenants_user = Tenants::User.create!(legacy_id: client.id,
                                               email: client.email,
                                               tenant_id: current_tenant.id).tap do |user|
            create_user_profile(tenants_user: user)
            create_user_group(tenants_user: user)
          end
          decorated_user = UserDecorator.decorate(tenants_user)
          render json: UserSerializer.new(decorated_user), status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render(json: {error: e.message}, status: :bad_request)
      end

      def password_reset
        random_password = SecureRandom.alphanumeric(16)
        client.update(password: random_password)
        render json: {data: {password: random_password}}
      end

      private

      def client
        @client ||= Tenants::User.find(params[:id])
      end

      def client_params
        client_keys = %i[email
          first_name
          last_name
          company_name
          role
          phone
          house_number
          street
          city
          postal_code
          group_id
          country]
        params.require(:client).permit(*client_keys)
      end

      def address_from_params
        {
          street_number: client_params[:house_number],
          street: client_params[:street],
          city: client_params[:city],
          zip_code: client_params[:postal_code],
          country: Legacy::Country.find_by(name: client_params[:country])
        }
      end

      def index_params
        params.permit(:q, :page, :per_page)
      end

      def create_user_profile(tenants_user:)
        profile_keys = %i[first_name last_name company_name phone]
        profile_params = client_params.slice(*profile_keys)
        Profiles::Profile.create!(profile_params.merge(user_id: tenants_user.id))
      end

      def create_user_group(tenants_user:)
        return if params[:group_id].nil?

        Tenants::Membership.create!(member: tenants_user, group_id: client_params[:group_id])
      end

      def decorated_clients
        query = index_params[:q]

        clients = Tenants::User.where(legacy_id: client_ids)
        clients = clients.search(query) if query.present?
        paginated = paginate(clients)

        UserDecorator.decorate_collection(paginated, { context: { links: pagination_links(paginated) }})
      end

      def client_ids
        blocked_roles = Legacy::Role.where(name: %w[admin super_admin])

        Legacy::User
          .where(tenant_id: current_tenant.legacy_id)
          .where(guest: false)
          .where.not(role: blocked_roles)
          .ids
      end
    end
  end
end
