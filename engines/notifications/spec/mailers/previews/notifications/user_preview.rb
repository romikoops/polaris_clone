module Notifications
  # Preview all emails at http://localhost:3000/rails/mailers/notifications/user
  class UserPreview < ActionMailer::Preview
    def activation_needed_email
      UserMailer.with(
        organization: organization,
        user: user
      ).activation_needed_email
    end

    def reset_password_email
      UserMailer.with(
        organization: organization,
        user: user
      ).reset_password_email
    end

    private

    def organization
      FactoryBot.build(:organizations_organization)
    end

    def user
      FactoryBot.build(:users_client, organization: organization)
    end
  end
end
