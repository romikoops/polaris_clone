# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::OffersController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:query) { FactoryBot.create(:journey_query) }
    let(:result) { FactoryBot.create(:journey_result, query: query) }
    let(:offer) { FactoryBot.create(:journey_offer, query: query, results: [result]) }
    let(:params) { {resultIds: [result.id], organization_id: organization.id} }

    describe "POST #create" do
      before { allow(controller).to receive(:new_offer).and_return(offer) }

      it "successfuly returns the Offer" do
        post :create, params: params, as: :json
        expect(response_data.dig("id")).to eq(offer.id)
      end
    end

    describe "GET #pdf" do
      let(:params) { {offer_id: offer.id, organization_id: organization.id} }

      it "successfuly returns the downlaod url for the PDF" do
        get :pdf, params: params, as: :json
        expect(response_data.dig("attributes", "url")).to be_present
      end
    end

    describe "GET #email" do
      before do
        allow(controller).to receive(:offer_mailer).and_return(mailer_spy)
      end

      let(:mailer_spy) { double("Notifications::ClientMailer::OfferEmail", deliver_now: true) }
      let(:params) { {offer_id: offer.id, organization_id: organization.id} }

      it "successfuly triggers the mailer" do
        get :email, params: params, as: :json
        expect(response.status).to eq(200)
        expect(mailer_spy).to have_received(:deliver_now)
      end
    end
  end
end
