# frozen_string_literal: true

class Admin::CompaniesController < Admin::AdminBaseController
  def index
    paginated_companies = handle_search.paginate(pagination_options)
    response_companies = paginated_companies.map do |page|
      for_table_json(table_company: page).deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end
    response_handler(
      pagination_options.merge(
        companiesData: response_companies,
        numPages: paginated_companies.total_pages
      )
    )
  end

  def show
    employees = Companies::Membership.where(company: company).map do |membership|
      user = membership.member
      ProfileTools.merge_profile(
        target: user.as_json,
        profile: Profiles::ProfileService.fetch(user_id: user.id)
      )
    end
    groups = Groups::Membership.where(member: company).map do |membership|
      group_index_json(membership.group)
    end
    response_handler(groups: groups, employees: employees, data: company)
  end

  def create
    new_company = ::Companies::Company.find_or_create_by(
      name: create_params[:name],
      email: create_params[:email],
      vat_number: create_params[:vatNumber],
      organization: current_organization,
      address: address_from_params
    )

    if create_params[:addedMembers].present?
      ::Organizations::User.where(id: create_params[:addedMembers]).each do |user|
        ::Companies::Membership.create!(member: user, company: new_company)
      end
    end

    response_handler(new_company)
  end

  def company
    @company ||= ::Companies::Company.find_by(id: params[:id])
  end

  def destroy
    company_to_destroy = company
    if company_to_destroy
      Companies::Membership.where(company: company_to_destroy).destroy_all
      company_to_destroy.destroy
      resp = company_to_destroy.destroyed? || company_to_destroy.deleted_at
    end
    response_handler(success: resp)
  end

  def edit_employees
    Companies::Membership.where(company: company).where.not(member_id: params[:addedMembers].pluck(:id)).destroy_all
    unless params[:addedMembers].nil? || params[:addedMembers].empty?
      params[:addedMembers].each do |user|
        Companies::Membership.create(company: company, member: ::Organizations::User.find(user[:id]))
      end
    end
    response_handler(company)
  end

  private

  def handle_search
    companies_relation = ::Companies::Company.where(organization: current_organization).left_joins(:address)
    {
      country: ->(query, param) { query.country_search(param) },
      name: ->(query, param) { query.name_search(param) },
      name_desc: ->(query, param) { query.ordered_by(:name, param) },
      vat_number: ->(query, param) { query.vat_search(param) },
      vat_number_desc: ->(query, param) { query.ordered_by(:vat_number, param) },
      address: ->(query, param) { query.address_search(param) },
      address_desc: ->(query, param) {
        query
        .order("#{address_table_ref}.geocoded_address #{search_params[:address_desc] == 'true' ? 'desc' : 'asc'}")
      },
      country_desc: lambda do |query, param|
                      query.left_joins(address: :country)
                      .order("#{country_table_ref}.name #{param.to_s == 'true' ? 'DESC' : 'ASC'}")
                    end
    }.each do |key, lambd|
      companies_relation = lambd.call(companies_relation, search_params[key]) if search_params[key]
    end

    companies_relation
  end

  def group_index_json(group, options = {})
    group.as_json(options).merge(
      margin_count: Pricings::Margin.where(applicable: group).count,
      member_count: group.memberships.size
    )
  end

  def for_table_json(table_company:)
    table_company.as_json.reverse_merge(
      address: table_company.address&.geocoded_address,
      country: table_company.address&.country&.name,
      employee_count: Companies::Membership.where(company: table_company).count
    )
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
      :vat_number,
      :vat_number_desc,
      :address,
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

  def address_params
    params.permit(address: %i[streetNumber street city zipCode country])
  end

  def create_params
    params.permit(:name, :email, :vatNumber, addedMembers: [])
  end

  def address_from_params
    return nil if address_params.empty?

    address_string = %i[streetNumber street city zipCode country].reduce('') do |memo, key|
      section = address_params.dig(:address, key)
      memo + (section.presence || '')
    end
    Legacy::Address.geocoded_address(address_string)
  end

  def country_table_ref
    return 'countries_addresses' if search_params[:country].present? && search_params[:country_desc].present?

    'countries'
  end

  def address_table_ref
    return 'addresses_companies_companies' if search_params[:address].present? && search_params[:address_desc].present?

    'addresses'
  end
end
