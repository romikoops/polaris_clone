# frozen_string_literal: true

class Admin::GroupsController < Admin::AdminBaseController
  def index
    paginated_groups = handle_search(params).paginate(pagination_options)
    response_groups = paginated_groups.map { |group|
      for_index_json(group).deep_transform_keys { |key| key.to_s.camelize(:lower) }
    }
    response_handler(
      pagination_options.merge(
        groupData: response_groups,
        numPages: paginated_groups.total_pages
      )
    )
  end

  def create
    group = ::Groups::Group.create(name: params[:name], organization: current_organization)
    params[:addedMembers].each do |type, _|
      params[:addedMembers][type].each do |new_member|
        create_member_from_type(group: group, type: type, member: new_member)
      end
    end
    response_handler(group)
  end

  def edit_members
    group = ::Groups::Group.find_by(id: params[:id])

    params[:addedMembers].each do |type, _|
      params[:addedMembers][type].each do |new_member|
        create_member_from_type(group: group, type: type, member: new_member)
      end
    end
    params_members_ids = params[:addedMembers].values.flatten.map { |param| param[:id].to_s }
    group.memberships.each do |membership|
      membership.destroy unless params_members_ids.include?(membership.member&.id)
    end
    response_handler(for_show_json(group))
  end

  def show
    response_handler(for_show_json(current_group))
  end

  def destroy
    group = current_group
    if group
      group.memberships.destroy_all
      Pricings::Margin.where(applicable: group).destroy_all
      group.destroy
    end
    response_handler(success: true)
  end

  def update
    group = current_group
    group&.update(edit_params) if group
    response_handler(for_show_json(group))
  end

  private

  def edit_params
    params.permit(:name)
  end

  def current_group
    ::Groups::Group.find_by(id: params[:id])
  end

  def create_member_from_type(group:, type:, member:)
    case type
    when "clients"
      user = ::Users::Client.find_by(id: member[:id])
      return nil unless user

      ::Groups::Membership.find_or_create_by(group_id: group.id, member: user)
    when "companies"
      company = ::Companies::Company.find_by(id: member[:id])
      return nil unless company

      ::Groups::Membership.find_or_create_by(group_id: group.id, member: company)
    when "groups"
      member_group = ::Groups::Group.find_by(id: member[:id])
      return nil unless member_group

      ::Groups::Membership.find_or_create_by(group_id: group.id, member: member_group)
    end
  end

  def groups
    @groups ||= ::Groups::Group.where(organization_id: current_organization.id)
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

  def handle_search(_params)
    query = groups
    if search_params[:target_type] && search_params[:target_id]
      case search_params[:target_type]
      when "company"
        query = query.joins(:memberships)
          .where(groups_memberships: {member_type: "Companies::Company", member_id: search_params[:target_id]})
      when "group"
        query = query.joins(:memberships)
          .where(groups_memberships: {member_type: "Groups::Group", member_id: search_params[:target_id]})
      when "user"
        query = query.joins(:memberships)
          .where(groups_memberships: {member_type: "Users::Client", member_id: search_params[:target_id]})
      end
    end
    query = query.order(name: search_params[:name_desc] == "true" ? :desc : :asc) if search_params[:name_desc]
    if search_params[:member_count_desc]
      sorting_direction = search_params[:member_count_desc] == "true" ? "DESC" : "ASC"
      query = query.left_joins(:memberships)
        .group("groups_groups.id")
        .order("COUNT(groups_memberships.id) #{sorting_direction}")
    end
    query = query.search(search_params[:query]) if search_params[:query]
    query = query.search(search_params[:name]) if search_params[:name]

    query
  end

  def for_index_json(group, options = {})
    new_options = options.reverse_merge(
      member_count: group.memberships.size,
      margin_count: Pricings::Margin.where(applicable: group).size
    )
    group.as_json.merge(new_options)
  end

  def for_show_json(group, options = {})
    group.as_json(options).reverse_merge(
      margins_list: Pricings::Margin.where(applicable: group).map { |m| margin_list_json(m) },
      member_list: group.memberships.map { |m| membership_list_json(m) }
    )
  end

  def margin_list_json(margin, options = {})
    new_options = options.reverse_merge(
      methods: %i[service_level itinerary_name fee_code cargo_class mode_of_transport],
      except: %i[margin_type]
    )
    margin.as_json(new_options).reverse_merge(
      marginDetails: margin.details.map { |d| detail_list_json(d) }
    ).deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def detail_list_json(detail, options = {})
    new_options = options.reverse_merge(
      methods: %i[rate_basis itinerary_name fee_code]
    )
    detail.as_json(new_options)
  end

  def membership_list_json(membership)
    info = member_info(membership: membership)
    membership.as_json.merge(info)
  end

  def member_info(membership:)
    case membership.member_type
    when "Users::Client"
      {
        member_name: membership.member.profile.full_name,
        human_type: "client",
        member_email: membership.member.email,
        original_member_id: membership.member_id
      }
    when "Companies::Company"
      {
        member_name: membership.member.name,
        human_type: "company",
        member_email: membership.member.email,
        original_member_id: membership.member_id
      }
    when "Groups::Group"
      {
        member_name: membership.member.name,
        human_type: "group",
        member_email: "",
        original_member_id: membership.member_id
      }
    end
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
