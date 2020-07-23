# frozen_string_literal: true

class ProfileTools
  def self.merge_profile(target:, profile: nil)
    profile ||= Profiles::Profile.with_deleted.find_by(user_id: target['id'])
    target.merge(profile.as_json(except: %i[user_id id]))
  end
end
