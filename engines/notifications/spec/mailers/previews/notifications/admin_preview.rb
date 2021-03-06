# frozen_string_literal: true

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
      query = FactoryBot.build(:journey_query, client: user, organization: organization)
      offer = FactoryBot.build(:journey_offer, query: query)

      AdminMailer.with(
        organization: organization,
        offer: offer,
        recipient: user.email
      ).offer_created
    end

    def shipment_request_created
      query = shipment_request.result.query
      Organizations.current_id = query.organization_id
      AdminMailer.with(
        organization: query.organization,
        shipment_request: shipment_request,
        recipient: query.client.email
      ).shipment_request_created
    end

    private

    def shipment_request
      @shipment_request ||= Journey::ShipmentRequest.first || FactoryBot.create(:journey_shipment_request, client: user, created_at: Time.zone.now)
    end

    def organization
      FactoryBot.build(:organizations_organization)
    end

    def user
      FactoryBot.build(:users_client, organization: organization)
    end
  end
end
