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

      def update
        ActiveRecord::Base.transaction do
          auth_user.update(email: client_params[:email])
          update_profile_from_params(user: client, params: profile_params)
          auth_user.save!
        end
      rescue ActiveRecord::RecordInvalid => e
        render(json: {error: e.message}, status: :unprocessable_entity)
      end

      def create
        ActiveRecord::Base.transaction do
          client = restored_client || new_client
          create_user_associations(user: client)
          decorated_user = UserDecorator.decorate(client)
          render json: UserSerializer.new(decorated_user), status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render(json: {error: e.message}, status: :bad_request)
      end

      def password_reset
        random_password = SecureRandom.alphanumeric(16)
        auth_user.update(password: random_password)
        render json: {data: {password: random_password}}
      end

      def destroy
        ActiveRecord::Base.transaction do
          profile.destroy!
          memberships.destroy_all
          auth_user.destroy!
        end
      end

      private

      def auth_user
        @auth_user ||= Authentication::User.find(params[:id])
      end

      def client
        @client ||= Organizations::User.find(params[:id])
      end

      def profile
        @profile ||= Profiles::Profile.find_by(user_id: client.id)
      end

      def memberships
        @memberships ||= Groups::Membership.where(member: client.id)
      end

      def client_params
        client_keys = %i[email
          first_name
          last_name
          company_name
          phone
          house_number
          street
          city
          postal_code
          group_id
          country]
        params.require(:client).permit(*client_keys)
      end

      def profile_params
        params.require(:client).permit(%i[first_name last_name company_name phone])
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

      def query
        index_params[:q]
      end

      def create_user_profile(user:)
        profile_keys = %i[first_name last_name company_name phone]
        profile_params = client_params.slice(*profile_keys)
        update_profile_from_params(user: user, params: profile_params)
      end

      def address
        @address ||= Legacy::Address.find_or_create_by!(address_from_params)
      end

      def create_user_group(user:)
        if params[:group_id].nil?
          attach_to_default_group(user: user)
        else
          Groups::Membership.create!(member: user, group_id: client_params[:group_id])
        end
      end

      def attach_to_default_group(user:)
        default_group = Groups::Group.find_by(organization_id: current_organization.id, name: 'default')
        return if default_group.blank?

        Groups::Membership.find_or_create_by(
          member: user,
          group: default_group
        )
      end

      def decorated_clients
        clients = Organizations::User.where(id: client_ids)

        if query.present?
          by_profile = filtered_profiles.pluck(:user_id)
          by_email = clients.search(query).select(:id)

          clients = clients.where(id: by_profile | by_email)
        end

        paginated = paginate(clients)
        UserDecorator.decorate_collection(paginated, { context: { links: pagination_links(paginated) }})
      end

      def filtered_profiles
        Profiles::Profile.where(user_id: client_ids).search(query)
      end

      def client_ids
        Organizations::User
          .where(organization_id: current_organization.id)
          .ids
      end

      def restored_client
        user_params = { email: client_params[:email], organization_id: current_organization }
        user = Organizations::User.with_deleted.find_by(user_params)
        restore_user_associations(user: user) if user

        user
      end

      def new_client
        Organizations::User.create!(email: client_params[:email], organization_id: current_organization.id)
      end

      def create_user_associations(user:)
        create_user_profile(user: user)
        create_user_group(user: user)
        Legacy::UserAddress.create(user: user, address: address)
      end

      def restore_user_associations(user:)
        user.restore
        [Profiles::Profile, Users::Settings].each do |relation|
          relation.with_deleted.find_by(user_id: user.id).restore
        end
      end
    end
  end
end
