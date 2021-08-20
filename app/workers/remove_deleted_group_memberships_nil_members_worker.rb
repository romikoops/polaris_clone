# frozen_string_literal: true

class RemoveDeletedGroupMembershipsNilMembersWorker
  include Sidekiq::Worker
  FailedDeletion = Class.new(StandardError)

  def perform
    Groups::Membership.where(id: group_memberships_to_be_deleted).destroy_all
    raise FailedDeletion unless group_memberships_to_be_deleted.empty?
  end

  def group_memberships_to_be_deleted
    [Users::Client.global, Companies::Company, Groups::Group].inject(Groups::Membership.none) do |relation, model|
      relation.or(Groups::Membership.where(member_type: model.name).where.not(member_id: model.ids))
    end
  end
end
