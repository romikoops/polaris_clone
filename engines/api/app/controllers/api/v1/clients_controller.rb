# frozen_string_literal: true

module Api
  module V1
    class ClientsController < ApiController
      include UsersUserAccess
      def index
        render json: ClientSerializer.new(decorated_clients)
      end

      def show
        render json: ClientSerializer.new(ClientDecorator.decorate(client))
      end

      def update
        unless client.update(email: client_params[:email], profile_attributes: profile_params.merge(id: client.profile_id))
          render(json: { error: client.errors.full_messages }, status: :unprocessable_entity)
          return
        end
        render json: ClientSerializer.new(ClientDecorator.decorate(client))
      end

      def create
        ActiveRecord::Base.transaction do
          decorated_user = ClientDecorator.decorate(new_client)
          render json: ClientSerializer.new(decorated_user), status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render(json: { error: e.message }, status: :bad_request)
      end

      def password_reset
        random_password = SecureRandom.alphanumeric(16)
        client.update(password: random_password)
        render json: { data: { password: random_password } }
      end

      def destroy
        user_services_client.destroy!
      end

      private

      def client
        @client ||= Users::Client.find(params[:id])
      end

      def user_services_client
        @user_services_client ||= ::UserServices::Client.find(params[:id])
      end

      def profile
        @profile ||= client.profile
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
        params.permit(*client_keys)
      end

      def profile_params
        params.permit(%i[first_name last_name company_name phone])
      end

      def index_params
        params.permit(:q, :page, :per_page, :sort_by, :direction)
      end

      def query
        index_params[:q]
      end

      def decorated_clients
        clients = Api::Client.where(id: client_ids)

        if query.present?
          by_profile = filtered_profiles.pluck(:user_id)
          by_email = clients.search(query).select(:id)

          clients = clients.where(id: by_profile | by_email)
        end

        clients = initialize_filterrific(
          clients,
          sort_by: index_params[:sort_by],
          direction: index_params[:direction].to_s.casecmp("DESC").zero? ? "DESC" : "ASC"
        ) || return

        paginated = paginate(clients.model_class)
        ClientDecorator.decorate_collection(paginated, { context: { links: pagination_links(paginated) } })
      end

      def filtered_profiles
        Users::ClientProfile.where(user_id: client_ids).search(query)
      end

      def client_ids
        Users::Client
          .where(organization_id: current_organization.id)
          .ids
      end

      def new_client
        Api::ClientCreationService.new(
          client_attributes: {
            email: client_params[:email],
            organization_id: current_organization.id
          },
          profile_attributes: profile_params,
          settings_attributes: { currency: current_scope[:default_currency] },
          group_id: params[:group_id]
        ).perform
      end
    end
  end
end
