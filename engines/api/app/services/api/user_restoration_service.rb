# frozen_string_literal: true

module Api
  class UserRestorationService
    def initialize(user_id:, organization_id:, params:)
      @organization = Organizations::Organization.find(organization_id)
      @user = Organizations::User.with_deleted.find(user_id)
      @params = params
    end

    def restore
      user.restore.tap do |user|
        restore_user_settings(user: user)
        restore_user_profile(user: user)
        restore_group_memberships(user: user)
      end
    end

    private

    attr_reader :user, :organization, :params

    def restore_user_settings(user:)
      Users::Settings.with_deleted.find_or_create_by(user_id: user.id).tap do |setting|
        return setting.restore if setting.deleted?

        setting.update(currency: scope.dig("default_currency"))
      end
    end

    def restore_user_profile(user:)
      Profiles::ProfileService.create_or_update_profile(**params.merge(user: user))
    end

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
