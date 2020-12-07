module Notifications
  # Preview all emails at http://localhost:3000/rails/mailers/notifications/user
  class UserPreview < ActionMailer::Preview
    def activation_needed_email
      UserMailer.with(
        organization: organization,
        user: user,
        profile: profile
      ).activation_needed_email
    end

    def reset_password_email
      UserMailer.with(
        organization: organization,
        user: user,
        profile: profile
      ).reset_password_email
    end

    private

    def organization
      FactoryBot.build(:organizations_organization)
    end

    def user
      FactoryBot.build(:organizations_user, organization: organization)
    end

    def profile
      FactoryBot.build(:profiles_profile, user: user)
    end
  end
end
