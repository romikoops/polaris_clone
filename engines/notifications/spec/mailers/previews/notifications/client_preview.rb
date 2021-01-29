module Notifications
  class ClientPreview < ActionMailer::Preview
    def offer_email
      ClientMailer.with(
        organization: organization,
        offer: offer,
        user: offer.query.client
      ).offer_email
    end

    private
    
    def organization
      offer.query.organization
    end

    def offer
      FactoryBot.build(:journey_offer)
    end
  end
end
