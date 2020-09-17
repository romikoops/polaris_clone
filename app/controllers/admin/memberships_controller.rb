# frozen_string_literal: true

class Admin::MembershipsController < Admin::AdminBaseController
  def bulk_edit
    active_memberships = Groups::Membership.where(member: target_member)

    active_memberships.each do |m|
      m.destroy unless params[:addedGroups].include?(m.group_id)
    end
    params[:addedGroups].sort_by { |g| }.each do |group_id|
      Groups::Membership.find_or_create_by(group_id: group_id, member: target_member)
    end

    params[:memberships].each do |m|
      membership = Groups::Membership.find_by(member: target_member, group_id: m[:group_id])
      membership&.update(priority: m[:priority])
    end

    target_member.reload
    active_memberships = Groups::Membership.where(member: target_member)
    response_handler(active_memberships)
  end

  def index
    memberships = Groups::Membership.all
    memberships = memberships.where(member: target_member) if target_member
    response_handler(memberships.map { |m| for_list_json(m) })
  end

  def destroy
    group = membership.group
    if membership.destroy
      response_handler(group)
    else
      response_handler(membership.errors)
    end
  end

  private

  def membership
    @membership ||= Groups::Membership.find(params[:id])
  end

  def target_member
    @target_member ||= if params[:targetId]
                         case params[:targetType]
                         when 'company'
                           Companies::Company.find(params[:targetId])
                         when 'group'
                           Groups::Group.find(params[:targetId])
                         when 'user'
                           Organizations::User.find(params[:targetId])
                         end
                       end
  end

  def for_list_json(membership, options = {})
    new_options = options.reverse_merge(member_info(membership: membership))
    membership.as_json.merge(new_options)
  end

  def member_info(membership:)
    case membership.member_type
    when 'Users::User'
      {
        member_name: Profiles::ProfileService.fetch(user_id: membership.member_id).full_name,
        human_type: 'client',
        member_email: membership.member.email,
        original_member_id: membership.member_id
      }
    when 'Companies::Company'
      {
        member_name: membership.member.name,
        human_type: 'company',
        member_email: membership.member.email,
        original_member_id: membership.member_id
      }
    when 'Groups::Group'
      {
        member_name: membership.member.name,
        human_type: 'group',
        member_email: '',
        original_member_id: membership.member_id
      }
    end
  end
end
