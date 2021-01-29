# frozen_string_literal: true

module Api
  class UserRestorationService
    def initialize(user_id:, organization_id:, params:)
      @organization = Organizations::Organization.find(organization_id)
      @user = Users::Client.with_deleted.find(user_id)
      @params = params
    end

    def restore
      user.restore.tap do |user|
        restore_group_memberships(user: user)
      end
    end

    private

    attr_reader :user, :organization, :params

    def restore_group_memberships(user:)
      Groups::Membership.with_deleted.where(member: user).each do |membership|
        membership.restore unless membership.group.deleted?
      end
    end

    def scope
      OrganizationManager::ScopeService.new(organization: organization).fetch
    end
  end
end
