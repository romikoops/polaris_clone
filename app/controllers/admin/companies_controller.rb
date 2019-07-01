# frozen_string_literal: true

class Admin::CompaniesController < ApplicationController
  def index
    paginated_companies = handle_search(params).paginate(pagination_options)
    response_companies = paginated_companies.map do |contact|
      contact.for_table_json.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end
    response_handler(
      pagination_options.merge(
        companiesData: response_companies,
        numPages: paginated_companies.total_pages
      )
    )
  end

  def show
    company = Tenants::Company.find_by(id: params[:id], sandbox: @sandbox)
    employees = Tenants::User.where(company_id: params[:id], sandbox: @sandbox).map(&:legacy)
    groups = company.groups.map { |g| group_index_json(g) }

    response_handler(groups: groups, employees: employees, data: company)
  end

  def create # rubocop:disable Metrics/AbcSize
    tenant = ::Tenants::Tenant.find_by(legacy_id: current_tenant.id, sandbox: @sandbox)
    address_string = [
      params[:address][:streetNumber],
      params[:address][:street],
      params[:address][:city],
      params[:address][:zipCode],
      params[:address][:country]
    ].join(', ')
    address = Legacy::Address.geocoded_address(address_string, @sandbox)
    company = ::Tenants::Company.find_or_create_by(
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
        tenants_user.company = company
        tenants_user.save!
      end
    end
    response_handler(company)
  end

  def edit_employees
    company = ::Tenants::Company.find_by(id: params[:id], sandbox: @sandbox)
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

  def handle_search(params)
    user = ::Tenants::User.find_by(legacy_id: current_user.id, sandbox: @sandbox)
    query = ::Tenants::Company.where(tenant_id: user.tenant_id, sandbox: @sandbox)
    query = query.country_search(params[:country]) if params[:country]
    query = query.name_search(params[:company_name]) if params[:company_name]
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
end
