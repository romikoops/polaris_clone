# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::ChargesController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
      shipment.charge_breakdowns.map(&:tender).each do |tender|
        Legacy::ExchangeRate.create(from: tender.amount.currency.iso_code,
                                    to: "USD", rate: 1.3,
                                    created_at: tender.created_at - 2.hours)
      end
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization_id: organization.id) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:quotation) { Quotations::Quotation.find_by(legacy_shipment_id: shipment.id) }
    let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }
    let(:tender) { shipment.charge_breakdowns.first.tender }
    let!(:shipment) do
      FactoryBot.create(:completed_legacy_shipment,
        with_full_breakdown: true, with_tenders: true, trip: trip, organization: organization, user: user)
    end
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "GET #show" do
      let(:tender_id) { quotation.tenders.first.id }
      let(:params) { {organization_id: organization.id, quotation_id: quotation.id, id: tender_id} }

      it "renders the chargs successfully" do
        get :show, params: params

        expect(response_data.dig("id")).to eq(tender_id)
      end
    end
  end
end
