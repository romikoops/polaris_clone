# frozen_string_literal: true

module Tenants
  class GroupManager
    def initialize(group_id:, actions:)
      @group = Tenants::Group.find(group_id)
      @tenant = @group.tenant
      @actions = actions
    end

    def perform
      handle_actions
    end

    def handle_actions
      @actions.each_key do |k|
        case k
        when :add
          add_to_group(@actions[:add])
        when :remove
          remove_from_group(@actions[:remove])
        end
      end
    end

    def add_to_group(members)
      members.each do |member|
        new_member = verify_member(member)
        ::Tenants::Membership.find_or_create_by(member: new_member, group: @group)
      end
    end

    def remove_from_group(members)
      members.each do |member|
        new_member = verify_member(member)
        ::Tenants::Membership.find_by(member: new_member, group: @group)&.destroy
      end
    end

    def verify_member(member)
      return member if [Tenants::User, Tenants::Group, Tenants::Company].include?(member.class)

      case member.class.to_s
      when 'User'
        return Tenants::User.find_by(legacy_id: member.id)
      when 'Legacy::User'
        return Tenants::User.find_by(legacy_id: member.id)
      end
    end
  end
end
