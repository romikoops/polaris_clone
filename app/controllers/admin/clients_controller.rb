# frozen_string_literal: true

class Admin::ClientsController < Admin::AdminBaseController
  # Return all clients and managers for dashboard

  def index
    clients, profiles = handle_search(params)
    paginated_clients = clients.paginate(pagination_options)
    response_clients = if search_params[:email_desc].present? || profiles.blank?
                         paginated_clients.map { |client| merge_profile(user: client) }
                       else
                         sort_response_clients(clients: paginated_clients, profiles: profiles)
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
    tenants_user = Tenants::User.find_by(legacy_id: client.id)
    profile = Profiles::Profile.find_by(user_id: tenants_user.id).as_json(except: %i[user_id id])
    client_data = client.token_validation_response.merge(profile)
    resp = { clientData: client_data, addresses: addresses, managerAssignments: manager_assignments, groups: groups }
    response_handler(resp)
  end

  # Api end point to create a new User through the Admin Dashboard
  def create
    json = JSON.parse(params[:new_client])
    user_data = {
      email: json['email'],
      password: json['password'],
      password_confirmation: json['password_confirmation'],
      sandbox: @sandbox,
      tenant_id: current_tenant.id
    }
    new_user = User.create(user_data)
    tenants_user = Tenants::User.find_by(legacy_id: new_user.id)
    profile = Profiles::ProfileService.create_or_update_profile(user: tenants_user,
                                                                first_name: json['firstName'],
                                                                last_name: json['lastName'],
                                                                company_name: json['companyName'],
                                                                phone: json['phone'])
    user_response = new_user.token_validation_response.merge(profile.as_json(except: %i[user_id id]))
    response_handler(user_response)
  end

  def agents
    handle_upload(
      params: upload_params,
      text: "#{current_tenant.subdomain}_clients",
      type: 'clients',
      options: {
        sandbox: @sandbox,
        user: current_user
      }
    )
  end

  # Destroy User account

  def destroy
    User.find_by(id: params[:id], sandbox: @sandbox).destroy
    response_handler(params[:id])
  end

  private

  def clients
    blocked_roles = Role.where(name: %w[admin super_admin])
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

  def handle_search(params)
    user_query = clients
    user_query = user_query.search(params[:query]) if params[:query]
    user_query = user_query.email_search(params[:email]) if params[:email]
    profile_query = handle_profile_search(clients: clients)
    if params[:company_name]
      user_ids =
        Tenants::User.where(
          company_id: ::Tenants::Company
                        .where(tenant_id: ::Tenants::Tenant.find_by(legacy_id: current_tenant.id).id)
                        .name_search(params[:company_name])
                        .ids
        ).ids
      profile_query = profile_query.where(user_id: user_ids)
    end
    # merge results from Tenant::User search and Profiles Search into one list
    clients = merge_search_results(users_search_results: user_query,
                                   profiles_search_results: profile_query)
    [clients, profile_query]
  end

  def handle_profile_search(clients:)
    return [] if params[:email] || params[:email_desc]

    tenant_user_ids = Tenants::User.where(legacy_id: clients.pluck(:id))
    query = Profiles::Profile.where(user_id: tenant_user_ids)
    query = query.search(params[:query]) if params[:query]
    query = query.first_name_search(params[:first_name]) if params[:first_name]
    query = query.last_name_search(params[:last_name]) if params[:last_name]
    query
  end

  def merge_search_results(users_search_results:, profiles_search_results:)
    user_ids = Tenants::User.where(id: profiles_search_results.pluck(:user_id)).pluck(:legacy_id)
    email_params_present = %i[email email_desc query].any? { |key| params[key] }
    users_search_results_ids = email_params_present ? users_search_results.pluck(:id) : []
    results = clients.where(id: [*user_ids, *users_search_results_ids].uniq)
    if search_params[:email_desc].present?
      results = results.reorder(email: search_params[:email_desc] == 'true' ? :desc : :asc)
    end
    results
  end

  def upload_params
    params.permit(:file)
  end

  def download_params
    params.require(:options).permit(:mot)
  end

  def group_index_json(group, options = {})
    new_options = options.reverse_merge(
      methods: %i[member_count margin_count]
    )
    group.as_json(new_options)
  end

  def merge_profile(user:, profile: nil)
    ProfileTools
      .merge_profile(target: user.for_admin_json, profile: profile)
      .deep_transform_keys { |key| key.to_s.camelize(:lower) }
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

  def sort_response_clients(clients:, profiles:)
    sort_keys = %i[first_name_desc last_name_desc company_name_desc]
    if sort_keys.any? { |key| params[key].present? }
      # fetch & order the profiles per the params first then match the clients accordingly
      sort_keys.each do |order_key|
        next if search_params[order_key].blank?

        key = order_key.to_s.gsub('_desc', '')
        order_params = { key => search_params[order_key] == 'true' ? :desc : :asc }
        profiles = profiles.reorder(order_params)
      end
    end
    profiles.map do |profile|
      legacy_user_id = Tenants::User.find(profile.user_id).legacy_id
      merge_profile(user: User.find(legacy_user_id), profile: profile)
    end
  end
end
