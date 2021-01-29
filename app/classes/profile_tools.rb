# frozen_string_literal: true

class ProfileTools
  def self.merge_profile(target:, profile: nil)
    profile ||= target.profile
    target.as_json.merge(profile.as_json(except: %i[user_id id]))
  end
end
