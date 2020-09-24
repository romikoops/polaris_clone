# frozen_string_literal: true

module Profiles
  class ProfileService
    def self.create_or_update_profile(**profile_params)
      user = profile_params.dig(:user)
      profile_attributes = {
        first_name: profile_params.dig(:first_name),
        last_name: profile_params.dig(:last_name),
        company_name: profile_params.dig(:company_name),
        external_id: profile_params.dig(:external_id),
        phone: profile_params.dig(:phone)
      }.compact

      if Profiles::Profile.with_deleted.exists?(user_id: user.id)
        profile = Profiles::Profile.with_deleted.find_by(user_id: user.id)
        profile.restore if profile.deleted?
        profile.update!(profile_attributes)
      else
        Profiles::Profile.create!(profile_attributes.merge(user_id: user.id))
      end
    end

    def self.fetch(user_id:)
      user_profile = user_id.nil? ? Profiles::Profile.new : Profiles::Profile.with_deleted.find_by(user_id: user_id)
      Profiles::ProfileDecorator.new(user_profile)
    end
  end
end
