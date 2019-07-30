# frozen_string_literal: true

class Admin::GroupsController < ApplicationController # rubocop:disable Metrics/ClassLength
  def index
    paginated_groups = handle_search(params).paginate(pagination_options)
    response_groups = paginated_groups.map do |group|
      for_index_json(group).deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end
    response_handler(
      pagination_options.merge(
        groupData: response_groups,
        numPages: paginated_groups.total_pages
      )
    )
  end

  def create
    tenant = ::Tenants::User.find_by(legacy_id: current_user.id, sandbox: @sandbox)&.tenant
    group = ::Tenants::Group.create(name: params[:name], tenant_id: tenant.id, sandbox: @sandbox)
    params[:addedMembers].keys.each do |type|
      params[:addedMembers][type].each do |new_member|
        create_member_from_type(group: group, type: type, member: new_member)
      end
    end
    response_handler(group)
  end

  def edit_members # rubocop:disable Metrics/AbcSize
    tenant = ::Tenants::User.find_by(legacy_id: current_user.id)&.tenant
    group = ::Tenants::Group.find_by(id: params[:id], tenant_id: tenant.id)

    params[:addedMembers].keys.each do |type|
      params[:addedMembers][type].each do |new_member|
        create_member_from_type(group: group, type: type, member: new_member)
      end
    end
    params_members_ids = params[:addedMembers].values.flatten.map { |param| param[:id].to_s }
    group.memberships.each do |membership|
      if membership.member.is_a?(Tenants::User)
        membership.destroy unless params_members_ids.include?(membership.member.legacy_id.to_s)
      else
        membership.destroy unless params_members_ids.include?(membership.member.id)
      end
    end
    response_handler(for_show_json(group))
  end

  def show
    group = ::Tenants::Group.find_by(id: params[:id], sandbox: @sandbox)
    response_handler(for_show_json(group))
  end

  def destroy
    group = Tenants::Group.find(params[:id])
    if group
      group.memberships.destroy_all
      group.margins.destroy_all
      group.destroy
    end
    response_handler(success: true)
  end

  private

  def create_member_from_type(group:, type:, member:) # rubocop:disable Metrics/CyclomaticComplexity
    case type
    when 'clients'
      user = ::Tenants::User.find_by(legacy_id: member[:id], sandbox: @sandbox)
      return nil unless user

      ::Tenants::Membership.find_or_create_by(group_id: group.id, member: user)
    when 'companies'
      company = ::Tenants::Company.find_by(id: member[:id], sandbox: @sandbox)
      return nil unless company

      ::Tenants::Membership.find_or_create_by(group_id: group.id, member: company)
    when 'groups'
      member_group = ::Tenants::Group.find_by(id: member[:id], sandbox: @sandbox)
      return nil unless member_group
      
      ::Tenants::Membership.find_or_create_by(group_id: group.id, member: member_group, sandbox: @sandbox)
    end
  end

  def groups
    tenant = ::Tenants::Tenant.find_by(legacy_id: current_tenant.id)
    @groups ||= ::Tenants::Group.where(tenant_id: tenant.id, sandbox: @sandbox)
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

  def handle_search(params) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
    query = groups
    if search_params[:target_type] && search_params[:target_id]
      case search_params[:target_type]
      when 'company'
        query = query.joins(:memberships)
                     .where(tenants_memberships: { member_type: 'Tenants::Company', member_id: search_params[:target_id] })
      when 'group'
        query = query.joins(:memberships)
                     .where(tenants_memberships: { member_type: 'Tenants::Group', member_id: search_params[:target_id] })
      when 'user'
        tenant_user = Tenants::User.find_by(legacy_id: search_params[:target_id], sandbox: @sandbox)
        group_ids = tenant_user.all_groups.ids
        query = query.where(id: group_ids)
      end
    end
    query = query.order(name: search_params[:name_desc] == 'true' ? :desc : :asc) if search_params[:name_desc]
    if search_params[:member_count_desc]
      query = query.left_joins(:memberships)
              .order("COUNT(tenants_memberships.id) #{search_params[:member_count_desc] == 'true' ? 'DESC' : 'ASC'}")
    end
    query = query.search(search_params[:query]) if search_params[:query]
    query = query.search(search_params[:name]) if search_params[:name]

    query
  end

  def for_index_json(group, options = {})
    new_options = options.reverse_merge(
      methods: %i(member_count margin_count)
    )
    group.as_json(new_options)
  end

  def for_show_json(group, options = {})
    group.as_json(options).reverse_merge(
      margins_list: group.margins.map { |m| margin_list_json(m) },
      member_list: group.memberships.map { |m| membership_list_json(m) }
    )
  end

  def margin_list_json(margin, options = {})
    new_options = options.reverse_merge(
      methods: %i(service_level itinerary_name fee_code cargo_class mode_of_transport),
      except: %i(margin_type)
    )
    margin.as_json(new_options).reverse_merge(
      marginDetails: margin.details.map { |d| detail_list_json(d) }
    ).deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def detail_list_json(detail, options = {})
    new_options = options.reverse_merge(
      methods: %i(rate_basis itinerary_name fee_code)
    )
    detail.as_json(new_options)
  end

  def membership_list_json(membership, options = {})
    new_options = options.reverse_merge(
      methods: %i(member_name human_type member_email original_member_id)
    )
    membership.as_json(new_options)
  end
  def search_params
    params.permit(
      :member_count_desc,
      :name_desc,
      :margin_count_desc,
      :name,
      :page_size,
      :per_page,
      :target_type,
      :target_id
    )
  end
end
