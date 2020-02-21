# frozen_string_literal: true

class Admin::MembershipsController < Admin::AdminBaseController
  def bulk_edit # rubocop:disable Metrics/AbcSize
    active_memberships = target_member.memberships.where(sandbox: @sandbox)
    active_memberships.each do |m|
      m.destroy unless params[:addedGroups].include?(m.group_id)
    end
    params[:addedGroups].sort_by { |g| }.each do |group_id|
      Tenants::Membership.find_or_create_by(group_id: group_id, member: target_member, sandbox: @sandbox)
    end

    params[:memberships].each do |m|
      membership = Tenants::Membership.find_by(member: target_member, group_id: m[:id], sandbox: @sandbox)
      membership&.update(priority: m[:priority])
    end

    target_member.reload
    active_memberships = target_member.memberships.where(sandbox: @sandbox)
    response_handler(active_memberships)
  end

  def membership_data
    memberships = Tenants::Membership.where(member: target_member, sandbox: @sandbox)
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
    @membership ||= Tenants::Membership.find(params[:id])
  end

  def target_member
    @target_member ||= if params[:targetId]
                         case params[:targetType]
                         when 'company'
                           Tenants::Company.find_by(id: params[:targetId], sandbox: @sandbox)
                         when 'group'
                           Tenants::Group.find_by(id: params[:targetId], sandbox: @sandbox)
                         when 'user'
                           Tenants::User.find_by(legacy_id: params[:targetId], sandbox: @sandbox)
                         end
                       end
  end

  def for_list_json(membership, options = {})
    new_options = options.reverse_merge(
      methods: %i[member_name human_type member_email original_member_id]
    )
    membership.as_json(new_options)
  end
end
