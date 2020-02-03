# frozen_string_literal: true

class Admin::CompaniesController < Admin::AdminBaseController
  def index
    paginated_companies = handle_search.paginate(pagination_options)
    response_companies = paginated_companies.map do |company|
      company.for_table_json.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end
    response_handler(
      pagination_options.merge(
        companiesData: response_companies,
        numPages: paginated_companies.total_pages
      )
    )
  end

  def show
    employees = company&.employees&.map(&:legacy) || []
    groups = company&.groups&.map { |g| group_index_json(g) } || []
    response_handler(groups: groups, employees: employees, data: company)
  end

  def create # rubocop:disable Metrics/AbcSize
    tenant = ::Tenants::Tenant.find_by(legacy_id: current_tenant.id)
    address_string = [
      params[:address][:streetNumber],
      params[:address][:street],
      params[:address][:city],
      params[:address][:zipCode],
      params[:address][:country]
    ].join(', ')
    address = Legacy::Address.geocoded_address(address_string, @sandbox)
    new_company = ::Tenants::Company.find_or_create_by(
      name: params[:name],
      email: params[:email],
      vat_number: params[:vatNumber],
      address: address,
      tenant: tenant,
      sandbox: @sandbox
    )
    unless params[:addedMembers].nil? || params[:addedMembers].empty?
      params[:addedMembers].each do |id|
        tenants_user = ::Tenants::User.find_by(legacy_id: id)
        tenants_user.company = new_company
        tenants_user.save!
      end
    end

    response_handler(new_company)
  end

  def company
    @company ||= ::Tenants::Company.find_by(id: params[:id], sandbox: @sandbox)
  end

  def destroy
    company_to_destroy = company
    if company_to_destroy
      company_to_destroy.employees.destroy_all
      result = company_to_destroy.destroy
      resp = result.destroyed? || result.deleted_at
    end
    response_handler(success: resp)
  end

  def edit_employees
    company.employees.each do |employee|
      employee.update(company: nil) unless params[:addedMembers].include?(employee.legacy_id)
    end
    unless params[:addedMembers].nil? || params[:addedMembers].empty?
      params[:addedMembers].each do |user|
        ::Tenants::User.find_by(legacy_id: user[:id], sandbox: @sandbox).update(company: company)
      end
    end
    response_handler(company)
  end

  private

  def handle_search
    user = ::Tenants::User.find_by(legacy_id: current_user.id, sandbox: @sandbox)
    query = ::Tenants::Company.where(tenant_id: user.tenant_id, sandbox: @sandbox)
    query = query.country_search(search_params[:country]) if search_params[:country].present?
    query = query.name_search(search_params[:name]) if search_params[:name].present?
    query = query.order(name: search_params[:name_desc] == 'true' ? :desc : :asc) if search_params[:name_desc].present?
    query = query.vat_search(search_params[:vat_number]) if search_params[:vat_number].present?
    if search_params[:vat_number_desc].present?
      query = query.order(vat_number: search_params[:vat_number_desc] == 'true' ? :desc : :asc)
    end
    if search_params[:address_desc]
      query = query.left_joins(:address)
                   .order(addresses: { geocoded_address: search_params[:address_desc] == 'true' ? 'DESC' : 'ASC' })
    end
    if search_params[:country_desc].present?
      query.left_joins(:address).left_joins(address: :country)
           .order(countries: { name: search_params[:address_desc] == 'true' ? 'DESC' : 'ASC' })
    end
    if search_params[:employee_count_desc].present?
      query = query.left_joins(:users).group(:id)
                   .order("COUNT(tenants_users.id) #{search_params[:member_count_desc] == 'true' ? 'DESC' : 'ASC'}")
    end
    query
  end

  def group_index_json(group, options = {})
    new_options = options.reverse_merge(
      methods: %i(member_count margin_count)
    )
    group.as_json(new_options)
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

  def search_params
    params.permit(
      :vat_number_desc,
      :address_desc,
      :name_desc,
      :country_desc,
      :employee_count_desc,
      :country,
      :name,
      :page_size,
      :per_page
    )
  end
end
