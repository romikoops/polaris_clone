# frozen_string_literal: true

module Api
  module V1
    class ClientsController < ApiController
      def index
        blocked_roles = Legacy::Role.where(name: %w[admin super_admin])
        client_ids = Legacy::User
                     .where(tenant_id: current_tenant.legacy_id)
                     .where(guest: false)
                     .where.not(role: blocked_roles)
                     .ids
        clients = Tenants::User.where(legacy_id: client_ids)

        render json: UserDecorator.decorate_collection(clients), each_serializer: UserSerializer
      end

      def show
        client = Tenants::User.find_by(legacy_id: params[:id])
        render json: UserDecorator.decorate(client), serializer: UserSerializer
      end

      def create
        ActiveRecord::Base.transaction do
          client = Legacy::User.create!(email: client_params[:email],
                                        tenant_id: current_tenant.legacy_id,
                                        addresses_attributes: [address_from_params],
                                        role: Legacy::Role.find_by(name: client_params[:role]))
          tenants_user = Tenants::User.create!(legacy_id: client.id,
                                               email: client.email,
                                               tenant_id: current_tenant.id).tap do |user|
            create_user_profile(tenants_user: user)
            create_user_group(tenants_user: user)
          end
          render json: UserDecorator.decorate(tenants_user), serializer: UserSerializer
        end
      rescue ActiveRecord::RecordInvalid => e
        render(json: { error: e.message }, status: :bad_request)
      end

      private

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

      def create_user_profile(tenants_user:)
        profile_keys = %i[first_name last_name company_name phone]
        profile_params = client_params.slice(*profile_keys)
        Profiles::Profile.create!(profile_params.merge(user_id: tenants_user.id))
      end

      def create_user_group(tenants_user:)
        Tenants::Membership.create!(member: tenants_user, group_id: client_params[:group_id])
      end
    end
  end
end
