module Notifications
  class AdminPreview < ActionMailer::Preview
    def user_created
      AdminMailer.with(
        organization: organization,
        user: user,
        recipient: user.email
      ).user_created
    end

    def offer_created
      query = FactoryBot.build(:journey_query, organization: organization)
      offer = FactoryBot.build(:journey_offer, query: query)

      AdminMailer.with(
        organization: organization,
        offer: offer,
        recipient: user.email
      ).offer_created
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
