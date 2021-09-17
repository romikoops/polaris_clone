# frozen_string_literal: true
require "rails_helper"

RSpec.describe QuotationsController, type: :controller do
  include_context "organization"
  include_context "journey_pdf_setup"

  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:token_header) { "Bearer #{access_token.token}" }

  before do
    request.headers["Authorization"] = token_header
    {USD: 1.26, SEK: 8.26}.each do |currency, rate|
      FactoryBot.create(:legacy_exchange_rate, from: currency, to: "EUR", rate: rate)
    end
  end

  describe "GET #show" do
    context "when successful quotation " do
      it "renders error code and message" do
        get :show, params: {organization_id: organization.id, id: query.id}

        expect(json.dig(:data, :quotationId)).to eq query.id
      end
    end

    context "when async error has occurred " do
      before { FactoryBot.create(:journey_error, query: query, code: 3002) }

      it "renders error code and message" do
        get :show, params: {organization_id: organization.id, id: query.id}

        aggregate_failures do
          expect(json.dig(:code)).to eq(3002)
          expect(json.dig(:message)).to eq "Your shipment has exceeded the load meterage limits for online booking."
        end
      end
    end
  end

  describe "GET #download_pdf" do
    context "when successful quotation " do
      it "renders error code and message" do
        get :download_pdf, params: {organization_id: organization.id, id: result.id}

        expect(json.dig(:data, :url)).to include("offer")
      end
    end
  end
end
