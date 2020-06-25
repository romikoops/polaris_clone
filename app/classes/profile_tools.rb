# frozen_string_literal: true

class ProfileTools
  def self.profile_for_user(legacy_user:)
    tenants_user = Tenants::User.find_by(legacy_id: legacy_user.id)
    Profiles::ProfileService.fetch(user_id: tenants_user.id)
  end

  def self.merge_profile(target:, profile: nil)
    tenants_user = Tenants::User.with_deleted.find_by(legacy_id: target['id'])
    profile ||= Profiles::Profile.with_deleted.find_by(user_id: tenants_user.id)
    target.merge(profile.as_json(except: %i[user_id id]))
  end
end
