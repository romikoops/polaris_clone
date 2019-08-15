# frozen_string_literal: true

class Admin::ClientsController < Admin::AdminBaseController
  # Return all clients and managers for dashboard

  def index
    paginated_clients = handle_search(params).paginate(pagination_options)
    response_clients = paginated_clients.map do |contact|
      contact.for_admin_json.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    response_handler(
      pagination_options.merge(
        clientData: response_clients,
        numPages: paginated_clients.total_pages
      )
    )
  end

  # Return selected User, assigned managers, shipments made and user addresses

  def show
    client = User.find_by(id: params[:id], sandbox: @sandbox)
    addresses = client.addresses
    groups = client.groups.map { |g| group_index_json(g) }
    manager_assignments = UserManager.where(user_id: client)
    resp = { clientData: client, addresses: addresses, managerAssignments: manager_assignments, groups: groups }
    response_handler(resp)
  end

  # Api end point to create a new User through the Admin Dashboard
  def create
    json = JSON.parse(params[:new_client])
    user_data = {
      email: json['email'],
      company_name: json['companyName'],
      first_name: json['firstName'],
      phone: json['phone'],
      last_name: json['lastName'],
      password: json['password'],
      password_confirmation: json['password_confirmation'],
      sandbox: @sandbox
    }
    new_user = current_user.tenant.users.create!(user_data)

    response_handler(new_user.token_validation_response)
  end

  def agents
    file = upload_params[:file].tempfile

    options = { tenant: current_tenant,
                file_or_path: file,
                options: { sandbox: @sandbox, user: current_user } }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    insertion_stats_or_errors = uploader.perform
    response_handler(insertion_stats_or_errors)
  end

  # Destroy User account

  def destroy
    User.find_by(id: params[:id], sandbox: @sandbox).destroy
    response_handler(params[:id])
  end

  private

  def clients
    blocked_roles = Role.where(name: %w(admin super_admin))
    @clients ||=  current_tenant.users
                                .where(guest: false, sandbox: @sandbox)
                                .where.not(role: blocked_roles)
                                .order(updated_at: :desc)
  end

  def pagination_options
    {
      page: current_page,
      per_page: (params[:page_size] || params[:per_page])&.to_f
    }.compact
  end

  def current_page
    params[:page]&.to_i || 1
  end

  def handle_search(params) # rubocop:disable Metrics/AbcSize
    query = clients
    query = query.search(params[:query]) if params[:query]
    query = query.first_name_search(params[:first_name]) if params[:first_name]
    query = query.last_name_search(params[:last_name]) if params[:last_name]
    query = query.email_search(params[:email]) if params[:email]
    if params[:company_name]
      user_ids =
        Tenants::User.where(
          company_id: ::Tenants::Company
                        .where(tenant_id: ::Tenants::Tenant.find_by(legacy_id: current_tenant.id).id)
                        .name_search(params[:company_name])
                        .ids
        ).pluck(:legacy_id)

      query = query.where(id: user_ids)
    end
    if search_params[:first_name_desc].present?
      query = query.reorder(first_name: search_params[:first_name_desc] == 'true' ? :desc : :asc)
    end
    if search_params[:last_name_desc].present?
      query = query.reorder(last_name: search_params[:last_name_desc] == 'true' ? :desc : :asc)
    end
    if search_params[:email_desc].present?
      query = query.reorder(email: search_params[:email_desc] == 'true' ? :desc : :asc)
    end
    if search_params[:company_name_desc].present?
      query = query.left_joins(tenants_user: :company)
                   .reorder("tenants_companies.name #{search_params[:company_name_desc] == 'true' ? 'desc' : 'asc'}")
    end

    query
  end

  def upload_params
    params.permit(:file)
  end

  def download_params
    params.require(:options).permit(:mot)
  end

  def group_index_json(group, options = {})
    new_options = options.reverse_merge(
      methods: %i(member_count margin_count)
    )
    group.as_json(new_options)
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
end
