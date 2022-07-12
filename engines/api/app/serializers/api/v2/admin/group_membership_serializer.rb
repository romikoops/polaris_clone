# frozen_string_literal: true

module Api
  module V2
    module Admin
      class GroupMembershipSerializer < Api::ApplicationSerializer
        attributes %i[id name member_type member_id group_id priority]

        attribute :group_name do |group_membership|
          group_membership.group.name
        end
      end
    end
  end
end
