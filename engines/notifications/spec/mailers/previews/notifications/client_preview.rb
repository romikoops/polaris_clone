# frozen_string_literal: true

module Notifications
  class ClientPreview < ActionMailer::Preview
    def offer_email
      ClientMailer.with(
        organization: organization,
        offer: offer,
        user: offer.query.client
      ).offer_email
    end

    def reset_password_email
      ClientMailer.with(
        organization: organization,
        user: client
      ).reset_password_email
    end

    def activation_needed_email
      ClientMailer.with(
        organization: organization,
        user: client
      ).activation_needed_email
    end

    private

    def organization
      offer.query.organization
    end

    def offer
      FactoryBot.build(:journey_offer)
    end

    def client
      FactoryBot.build(:users_client, organization: organization)
    end
  end
end
