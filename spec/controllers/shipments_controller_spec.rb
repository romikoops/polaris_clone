# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShipmentsController do
  include_context "journey_complete_request"

  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { query.client }
  let(:json_response) { JSON.parse(response.body) }
  let(:origin_hub) {
    FactoryBot.create(:legacy_hub,
      hub_code: freight_section.from.locode,
      hub_type: freight_section.mode_of_transport,
      organization: organization)
  }
  let(:destination_hub) {
    FactoryBot.create(:legacy_hub,
      hub_code: freight_section.to.locode,
      hub_type: freight_section.mode_of_transport,
      organization: organization)
  }
  let!(:origin_nexus) {
    origin_hub.nexus
  }
  let!(:destination_nexus) {
    destination_hub.nexus
  }
  let(:route_sections) { [freight_section] }
  let(:line_items) { freight_line_items_with_cargo }

  before do
    Organizations.current_id = organization.id
    breakdown
    append_token_header
  end

  describe "GET #index" do
    it "returns an http status of success" do
      get :index, params: {organization_id: organization.id}

      expect(response_data["quoted"].map { |res| res["id"] }).to match([result.id])
    end
  end

  describe "GET #delta_page_handler" do
    it "returns the results for the page in question", :aggregate_failures do
      get :delta_page_handler, params: {organization_id: organization.id, page: 1, per_page: 1, target: "quoted"}

      expect(response_data["shipments"].count).to eq(1)
      expect(response_data["page"]).to eq("1")
    end
  end

  describe "GET #search_shipments" do
    it "returns the results for the page in question" do
      get :search_shipments, params: {
        organization_id: organization.id, page: 1, per_page: 1, target: "quoted", query: query.origin
      }

      expect(response_data["shipments"].pluck("id")).to eq([result.id])
    end
  end

  describe "GET #show" do
    before do
      %w[
        trucking_pre
        trucking_on
        cargo
        export
        import
      ].each do |code|
        FactoryBot.create(:legacy_charge_categories, code: code, name: code.humanize, organization: organization)
      end
    end

    let!(:target_exchange_rate) { FactoryBot.create(:treasury_exchange_rate, from: "EUR", to: "USD") }

    it "returns requested result" do
      get :show, params: {id: result.id, organization_id: organization.id}

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response.dig("data", "exchange_rates")).to include(
          "base" => "EUR", "usd" => target_exchange_rate.rate.round(2).to_s
        )
      end
    end

    it "returns 404 when a shipment id is provided" do
      get :show, params: {id: 1, organization_id: organization.id}

      aggregate_failures do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "Patch #update_user" do
    context "with shipment" do
      before do
        patch :update_user, params: {organization_id: organization.id, id: result.id}
        result.reload
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates the shipment user" do
        expect(query.client_id).to eq(user.id)
      end
    end

    context "when shipment is deleted" do
      before do
        result.destroy
        patch :update_user, params: {organization_id: organization.id, id: result.id}
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
