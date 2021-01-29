# frozen_string_literal: true

class Admin::ClientsController < Admin::AdminBaseController
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

  # Return selected User, assigned managers, shipments made and user addresses

  def show
    client = Users::Client.find_by(organization_id: params[:organization_id], id: params[:id])
    addresses = Address.joins(:user_addresses).where(user_addresses: {user_id: client.id})
    groups = target_groups(target: client).map { |g| group_index_json(g) }
    manager_assignments = UserManager.where(user_id: client.id)
    profile = client.profile.as_json(except: %i[user_id id])
    client_data = client.as_json.merge(profile)
    resp = {clientData: client_data, addresses: addresses, managerAssignments: manager_assignments, groups: groups}
    response_handler(resp)
  end

  # Api end point to create a new User through the Admin Dashboard
  def create
    user_data = {
      email: new_client_params["email"],
      password: new_client_params["password"],
      password_confirmation: new_client_params["password_confirmation"],
      organization_id: current_organization.id
    }
    ActiveRecord::Base.transaction do
      user = restorable_client ? restore_client(user_data: user_data) : create_client(user_data: user_data)
      user_response = serialized_user(user: user)
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
      type: "clients",
      options: {
        user: organization_user
      }
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
      per_page: (params[:page_size] || params[:per_page] || DEFAULT_PAGE_SIZE)&.to_f
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
          "#{order_clause} #{search_params[order_key] == "true" ? "DESC" : "ASC"}"
        )
      end
      query
    end

    query.map do |user|
      user.as_json.merge!(user.profile.as_json.except("id"))
        .deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end
  end

  def create_client(user_data:)
    Users::Client.create!(user_data.merge(profile_attributes: profile_params, settings_attributes: {}))
  end

  def restorable_client
    @restorable_client ||= begin
      email = new_client_params.dig("email")
      Users::Client.only_deleted.find_by(email: email)
    end
  end

  def restore_client(user_data:)
    restoration_params = {user_id: restorable_client.id,
                          organization_id: current_organization.id,
                          params: profile_params}
    Api::UserRestorationService.new(**restoration_params).restore.tap do |user|
      Users::Client.find(user.id).update(user_data.slice(:password, :password_confirmation))
    end
  end

  def new_client_params
    JSON.parse(params[:new_client])
  end

  def profile_params
    {
      first_name: new_client_params["firstName"],
      last_name: new_client_params["lastName"],
      company_name: new_client_params["companyName"],
      phone: new_client_params["phone"]
    }
  end
end
