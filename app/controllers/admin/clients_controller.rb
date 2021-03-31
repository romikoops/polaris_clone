# frozen_string_literal: true

module Admin
  class ClientsController < Admin::AdminBaseController
    # Return all clients and managers for dashboard
    DEFAULT_PAGE_SIZE = 50

    def index
      paginated_clients = handle_search(params).paginate(pagination_options)
      response_handler(
        pagination_options.merge(
          clientData: sort_response_clients(query: paginated_clients),
          numPages: paginated_clients.total_pages
        )
      )
    end

    # Return selected User, assigned managers, groups and user addresses
    def show
      client = Users::Client.find_by(organization_id: params[:organization_id], id: params[:id])
      addresses = Address.joins(:user_addresses).where(user_addresses: { user_id: client.id })
      groups = target_groups(target: client).map { |group| group_index_json(group) }
      manager_assignments = UserManager.where(user_id: client.id)
      profile = client.profile.as_json(except: %i[user_id id])
      client_data = client.as_json.merge(profile)
      resp = { clientData: client_data, addresses: addresses, managerAssignments: manager_assignments, groups: groups }
      response_handler(resp)
    end

    # Api end point to create a new User through the Admin Dashboard
    def create
      ActiveRecord::Base.transaction do
        user_response = serialized_user(user: new_client)
        response_handler(user_response)
      end
    rescue ActiveRecord::RecordInvalid => e
      response_handler(
        ApplicationError.new(
          http_code: 422,
          message: e.message
        )
      )
    end

    def agents
      handle_upload(
        params: upload_params,
        text: "#{current_organization.slug}_clients",
        type: "clients"
      )
    end

    # Destroy User account

    def destroy
      ActiveRecord::Base.transaction do
        user = Users::Client.find_by(id: params[:id])
        Groups::Membership.where(member: user).destroy_all
        Companies::Membership.where(member: user).destroy_all
        user.destroy!
      end

      response_handler(params[:id])
    end

    private

    def serialized_user(user:)
      Api::V1::UserSerializer.new(Api::V1::UserDecorator.decorate(user))
    end

    def clients
      @clients ||= Users::Client.where(organization_id: current_organization.id)
        .order(updated_at: :desc)
    end

    def profiles
      @profiles ||= Users::ClientProfile.where(user: clients)
    end

    def pagination_options
      {
        page: current_page,
        per_page: (params[:page_size] || params[:per_page] || DEFAULT_PAGE_SIZE)&.to_i
      }.compact
    end

    def current_page
      params[:page]&.to_i || 1
    end

    def handle_search(params)
      query = profiles
      query = query.search(params[:query]) if params[:query]
      query = query.search(params[:email]) if params[:email]
      query = clients.where(id: query.select(:user_id)).joins(:profile)

      return query if params[:company_name].blank?

      query.joins(
        "JOIN companies_memberships ON companies_memberships.member_id = users_clients.id
          JOIN companies_companies ON companies_companies.id = companies_memberships.company_id"
      ).where("companies_companies.name ILIKE ?", "%#{params[:company_name]}")
    end

    def upload_params
      params.permit(:async, :file)
    end

    def download_params
      params.require(:options).permit(:mot)
    end

    def group_index_json(group, options = {})
      group.as_json(options).merge(
        margin_count: Pricings::Margin.where(applicable: group).count,
        member_count: group.memberships.size
      )
    end

    def search_params
      params.permit(
        :first_name_desc,
        :last_name_desc,
        :email_desc,
        :company_name_desc,
        :first_name,
        :last_name,
        :email,
        :company_name,
        :page_size,
        :per_page
      )
    end

    def sort_response_clients(query:)
      order_clauses = {
        first_name_desc: "users_client_profiles.first_name",
        last_name_desc: "users_client_profiles.last_name",
        company_name_desc: "companies_companies.name",
        email_desc: "users_client.email"
      }
      if order_clauses.keys.any? { |key| params[key].present? }
        order_clauses.each do |order_key, order_clause|
          next if search_params[order_key].blank?

          query = query.reorder(
            "#{order_clause} #{search_params[order_key] == 'true' ? 'DESC' : 'ASC'}"
          )
        end
        query
      end

      query.map do |user|
        user.as_json.merge!(user.profile.as_json.except("id"))
          .deep_transform_keys { |key| key.to_s.camelize(:lower) }
      end
    end

    def new_client
      Api::ClientCreationService.new(
        client_attributes: client_params,
        profile_attributes: profile_params,
        settings_attributes: { currency: current_scope[:default_currency] },
        group_id: params[:group_id]
      ).perform
    end

    def profile_params
      {
        first_name: create_params[:firstName],
        last_name: create_params[:lastName],
        company_name: create_params[:companyName],
        phone: create_params[:phone]
      }
    end

    def client_params
      {
        email: new_client_email,
        password: new_client_password,
        password_confirmation: new_client_password_confirmation,
        organization_id: current_organization.id
      }
    end

    def create_params
      params.require(:client).permit(%i[
        firstName
        lastName
        email
        phone
        companyName
        password
        password_confirmation
      ])
    end

    def new_client_email
      create_params.require(:email)
    end

    def new_client_password
      create_params.require(:password)
    end

    def new_client_password_confirmation
      create_params.require(:password_confirmation)
    end
  end
end
