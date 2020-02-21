# frozen_string_literal: true

module Profiles
  class ProfileService
    def self.create_or_update_profile(user:, first_name:, last_name:, company_name: nil, phone: nil)
      profile_attributes = {
        user_id: user.id,
        first_name: first_name,
        last_name: last_name,
        company_name: company_name,
        phone: phone
      }
      if Profiles::Profile.exists?(user_id: user.id)
        Profiles::Profile.find_by(user_id: user.id).update(profile_attributes)
      else
        Profiles::Profile.create(profile_attributes)
      end
    end

    def self.fetch(user_id:)
      user_profile = Profiles::Profile.find_by(user_id: user_id)
      Profiles::ProfileDecorator.new(user_profile)
    end
  end
end
