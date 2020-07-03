# frozen_string_literal: true

module Groups
  class GroupManager
    def initialize(group_id:, actions:)
      @group = Groups::Group.find(group_id)
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
        ::Groups::Membership.find_or_create_by(member: member, group: @group)
      end
    end

    def remove_from_group(members)
      members.each do |member|
        ::Groups::Membership.find_by(member: member, group: @group)&.destroy
      end
    end
  end
end
