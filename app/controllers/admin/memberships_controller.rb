# frozen_string_literal: true

class Admin::MembershipsController < ApplicationController
  def bulk_edit # rubocop:disable Metrics/AbcSize
    active_memberships = target_member.memberships
    active_memberships.each do |m|
      m.destroy unless params[:addedGroups].include?(m.group_id)
    end
    params[:addedGroups].sort_by { |g| }.each do |group_id|
      Tenants::Membership.find_or_create_by(group_id: group_id, member: target_member)
    end

    params[:memberships].each do |m|
      membership = Tenants::Membership.find_by(member: target_member, group_id: m[:id])
      membership&.update(priority: m[:priority])
    end

    target_member.reload
    active_memberships = target_member.memberships
    response_handler(active_memberships)
  end

  def membership_data
    memberships = Tenants::Membership.where(member: target_member)
    response_handler(memberships.map { |m| for_list_json(m) })
  end

  private

  def target_member
    @target_member ||= if params[:targetId]
                         case params[:targetType]
                         when 'company'
                           Tenants::Company.find(params[:targetId])
                         when 'group'
                           Tenants::Group.find(params[:targetId])
                         when 'user'
                           Tenants::User.find_by(legacy_id: params[:targetId])
                         end
                       end
  end

  def for_list_json(membership, options = {})
    new_options = options.reverse_merge(
      methods: %i(member_name human_type member_email original_member_id)
    )
    membership.as_json(new_options)
  end
end
