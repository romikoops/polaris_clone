module Notifications
  class AdminPreview < ActionMailer::Preview
    def user_created
      organization = FactoryBot.build(:organizations_organization)
      user = FactoryBot.build(:organizations_user, organization: organization)
      profile = FactoryBot.build(:profiles_profile, user: user)

      AdminMailer.with(
        organization: organization,
        user: user,
        profile: profile,
        recipient: user.email
      ).user_created
    end
  end
end
