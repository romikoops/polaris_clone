# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShipmentsController do
  let(:user) { FactoryBot.create(:organizations_user_with_profile) }
  let(:organization) { user.organization }
  let(:shipment) { FactoryBot.create(:shipment, user: user, organization: organization) }
  let(:json_response) { JSON.parse(response.body) }

  before do
    append_token_header
  end

  describe "GET #index" do
    it "returns an http status of success" do
      get :index, params: {organization_id: organization.id}

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    let(:shipment) {
      FactoryBot.create(:legacy_shipment, user: user, organization: organization, with_breakdown: true)
    }
    let(:tender) {
      FactoryBot.create(:quotations_tender, amount: tender_amount, created_at: 15.minutes.ago)
    }
    let(:tender_amount) { Money.new(100, "EUR") }
    let(:rate) { 1.24 }

    before do
      FactoryBot.create(:legacy_exchange_rate)
      Legacy::ExchangeRate.create(from: tender_amount.currency.iso_code, to: "USD", rate: rate,
                                  created_at: 16.minutes.ago)
      shipment.charge_breakdowns.update_all(tender_id: tender.id)
      FactoryBot.create_list(:quotations_line_item, 5, tender: tender)
    end

    it "returns requested shipment" do
      get :show, params: {id: shipment.id, organization_id: organization.id}
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response.dig("data", "exchange_rates")).to include("base" => "EUR", "usd" => rate.to_s)
      end
    end
  end

  describe "Patch #update_user" do
    context "with shipment" do
      before do
        patch :update_user, params: {organization_id: organization.id, id: shipment.id}
        shipment.reload
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates the shipment user" do
        expect(shipment.user_id).to eq(user.id)
      end
    end

    context "when shipment is deleted" do
      before do
        shipment.destroy
        patch :update_user, params: {organization_id: organization.id, id: shipment.id}
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST #upload_document" do
    before do
      post :upload_document, params: {
        "file" => Rack::Test::UploadedFile.new(File.expand_path("../test_sheets/spec_sheet.xlsx", __dir__)),
        :shipment_id => shipment.id, :organization_id => organization.id, :type => "packing_sheet"
      }
    end

    it "returns the document with the signed url" do
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response["data"]).not_to be_empty
        expect(json_response.dig("data", "signed_url")).to be_truthy
      end
    end
  end
end
